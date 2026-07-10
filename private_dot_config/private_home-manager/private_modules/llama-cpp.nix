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
      # Use -m with direct path to the cached GGUF file instead of -hf
      # -hf re-downloads from HuggingFace on every start, wasting time and bandwidth
      # The model was pre-downloaded via HuggingFace cache at:
      #   ~/.cache/huggingface/hub/models--ggml-org--gemma-4-26B-A4B-it-GGUF/snapshots/.../gemma-4-26B-A4B-it-Q4_K_M.gguf
      ExecStart = "${lib.getExe' pkgs.llama-cpp "llama-server"} -m /home/papanito/.cache/huggingface/hub/models--ggml-org--gemma-4-26B-A4B-it-GGUF/snapshots/ae4d537a6345467d1c86bb5cc0d4505ff3ebe0f3/gemma-4-26B-A4B-it-Q4_K_M.gguf --alias ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_K_M --host 127.0.0.1 --port 8080";
      Restart = "on-failure";
      RestartSec = 5;
      # Give it time to load the model into RAM (16GB model)
      TimeoutStartSec = 120;
      # SIGINT is the graceful shutdown signal for llama-server
      KillSignal = "SIGINT";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}