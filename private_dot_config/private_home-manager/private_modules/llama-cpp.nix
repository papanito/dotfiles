{ pkgs, lib, ... }:

{
  # llama.cpp server — serves one model at a time via OpenAI-compatible API
  # Started as a user systemd service so it auto-launches on login
  systemd.user.services.llama-cpp = {
    Enable = true;
    description = "llama.cpp server (local LLM inference)";

    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.llama-cpp "llama-server"} -hf ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_K_M --host 127.0.0.1 --port 8080";
      Restart = "on-failure";
      RestartSec = 5;
      # Give it time to load the model into RAM (16GB model)
      TimeoutStartSec = 120;
    };

    # Don't start if ollama is already using port 8080 (it shouldn't, but guard)
    unitConfig = {
      After = [ "ollama.service" ];
    };

    wantedBy = [ "default.target" ];
  };
}