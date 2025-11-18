with import <nixpkgs> {};
let
   basePackages = [
     erlang_28
     elixir_1_17
     elixir-ls
     lexical
     inotify-tools
   ];
  PROJECT_ROOT = builtins.toString ./.;

  ## Hooks are not necessary but make things more convenient.
  hooks = ''
    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=${PROJECT_ROOT}/.nix-mix
    export HEX_HOME=${PROJECT_ROOT}/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export LANG=en_IN.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"
    '';

  in mkShell {
    buildInputs = basePackages;
    shellHook = hooks;
  }
