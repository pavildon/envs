{
  description = "Dev env for ocaml";

  inputs = {
     fzf_tmux_kak = {
       url = "github:jpe90/fzf-tmux.kak";
       flake = false;
     };

     clp_src= {
       url = "github:jpe90/clp";
       flake = false;
     };

  };

    outputs = { self, clp_src, fzf_tmux_kak, nixpkgs }:
    let
    	pkgs = nixpkgs.legacyPackages.x86_64-linux;

    	clp = pkgs.llvmPackages_15.libcxxStdenv.mkDerivation
    	{
          name = "clp";
          src = clp_src;
          buildInputs = [ pkgs.pkg-config pkgs.luajit pkgs.luajitPackages.lpeg pkgs.luajitPackages.luautf8 ];
    	};

    in {
      devShells.x86_64-linux.default =
        pkgs.mkShell.override {stdenv = pkgs.llvmPackages_15.libcxxStdenv;}
        {
          name = "Dev env";

          gccwrap = ./bin;
          kakrc = ./config/kak;
          kak_lsp_cfg = ./config/kak-lsp/kak-lsp.toml;
          kak_fzf = fzf_tmux_kak;
          clp = clp;

          shellHook = ''
              export ENV_NAME="kak"
              export KAKOUNE_CONFIG_DIR="$kakrc"
              # export OCAMLPARAM="verbose=1,_"
              export PATH=$PATH:$clp:$gccwrap
              export EDITOR=kak
              eval $(opam env)
          '';

	  inputsFrom = [ clp ];

          buildInputs = [
              pkgs.zsh

              pkgs.fzf
              pkgs.fd

              pkgs.kakoune
              pkgs.kak-lsp
              pkgs.nil

              pkgs.opam

              clp
          ];
        };
    };
}
