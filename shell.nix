{
  pkgs,
  lib
}: let
  basePackages = with pkgs; [
    elixir
    hex
    mix2nix
  ];
in
  pkgs.mkShell {
    buildInputs = with pkgs;
      basePackages
      ++ lib.optionals stdenv.isLinux [inotify-tools]
      ++ lib.optionals stdenv.isDarwin
      (with darwin.apple_sdk.frameworks; [CoreFoundation CoreServices]);

    shellHook = ''
      mkdir -p .nix-mix
      mkdir -p .nix-hex
      export MIX_HOME=$PWD/.nix-mix
      export HEX_HOME=$PWD/.nix-hex
      export PATH=$MIX_HOME/bin:$PATH
      export PATH=$HEX_HOME/bin:$PATH

      export LANG=en_US.UTF-8
      export ERL_AFLAGS="-kernel shell_history enabled"
    '';
  }
