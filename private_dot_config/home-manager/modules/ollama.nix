{ pkgs, ... }:

{
  # Install the binary for CLI usage
  home.packages = [ pkgs.ollama ];

  services.ollama = {
    enable = true;
    # acceleration = "cuda"; # Uncomment if using NVIDIA

    # Environment variables for the Ollama server
    environmentVariables = {
      OLLAMA_HOST = "127.0.0.1:11434";
      OLLAMA_ORIGINS = "vscode-webview://*,chrome-extension://*,*"; # Helpful for browser tools
    };
  };
}
