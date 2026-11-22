{ config, pkgs, ... }:

{
  services.pueue = {
    enable = true;
    # Optional: Configure the daemon behavior
    settings = {
      shared = {
        # Use a custom socket path if desired, defaults to $XDG_RUNTIME_DIR/pueue.socket
        # use_unix_socket = true;
      };
      daemon = {
        default_parallel_tasks = 2;
      };
    };
  };
}

