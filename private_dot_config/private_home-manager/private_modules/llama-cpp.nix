{ pkgs, lib, ... }:

{
  # llama.cpp server — serves one model at a time via OpenAI-compatible API
  # Started as a user systemd service so it auto-launches on login
  # Modeled after the NixOS services.llama-cpp module, adapted for Home Manager
  systemd.user.services.llama-cpp = {
    Unit = {
      Description = "llama.cpp server (local LLM inference)";
      After = [ "network.target" ];
    };

    Service = {
      Type = "idle";
      # -hf downloads from HuggingFace if not cached, then serves the model
      # Uses LLAMA_CACHE from environment for model cache directory
      ExecStart = "${lib.getExe' pkgs.llama-cpp "llama-server"} -hf ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_K_M --host 127.0.0.1 --port 8080";
      Restart = "on-failure";
      RestartSec = 5;
      # Give it time to load the model into RAM (16GB model)
      TimeoutStartSec = 120;
      # SIGINT is the graceful shutdown signal for llama-server
      KillSignal = "SIGINT";
      Environment = [ "LLAMA_CACHE=%h/.cache/llama-cpp" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}