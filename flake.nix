{
  description = "A very basic flake";

  inputs = {
     fzf_tmux_kak = {
       url = "github:jpe90/fzf-tmux.kak";
       flake = false;
     };
  };

  outputs = { self, fzf_tmux_kak, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default =
        pkgs.mkShell.override {stdenv = pkgs.llvmPackages_15.libcxxStdenv;}
        {
          name = "Dev env";

          gccwrap = ./bin;
          kakrc = ./config/kak;
          kak_lsp_cfg = ./config/kak-lsp/kak-lsp.toml;
          kak_fzf = fzf_tmux_kak;

          shellHook = ''
              export ENV_NAME="kak"
              export KAKOUNE_CONFIG_DIR="$kakrc"
              # export OCAMLPARAM="verbose=1,_"
              export PATH=$PATH:$gccwrap
              export EDITOR=kak
          '';

          buildInputs = [
              pkgs.zsh

              pkgs.fzf
              pkgs.clp
              pkgs.fd

              pkgs.kakoune
              pkgs.kak-lsp
              pkgs.nil
              pkgs.ocaml
              pkgs.opam
              pkgs.ocamlformat

              pkgs.ocamlPackages.ocaml-lsp
              pkgs.ocamlPackages.dune_3
              pkgs.ocamlPackages.utop
          ];
        };
    };
}
