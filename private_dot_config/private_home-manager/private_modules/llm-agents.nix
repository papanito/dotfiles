# AI coding agents / agent tooling from numtide/llm-agents.nix.
#
# The packages come from the `llm-agents` flake input through the
# `llm-agents.overlays.shared-nixpkgs` overlay wired in flake.nix, so they live
# at `pkgs.llm-agents.<name>` and inherit our nixpkgs config. Upstream bumps
# them daily — run `nix flake lock --update-input llm-agents` to pick that up.
{ pkgs, ... }:
{
  home.packages = with pkgs.llm-agents; [
    opencode2 # OpenCode 2 CLI (v2 line; the binary installs as `opencode2`, see opencode-server service)
    qwen-code # Command-line AI workflow tool for Qwen3-Coder models
    antigravity-cli # Agentic development platform, evolving the IDE into the agent-first era
    rtk # CLI proxy that reduces LLM token consumption by 60-90% on common dev commands
    orca # Orca ADE (orca.dev) — desktop app `orca-ide` + `orca` CLI for parallel coding agents
  ];
}
