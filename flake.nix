{
  description = "Dev env for ocaml";
  inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

     zig-overlay.url = "github:mitchellh/zig-overlay";
     zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

     zls.url = "github:zigtools/zls";
     zls.inputs.nixpkgs.follows = "nixpkgs";

     fzf_tmux_kak = {
       url = "github:jpe90/fzf-tmux.kak";
       flake = false;
     };

     clp_src= {
       url = "github:jpe90/clp";
       flake = false;
     };

  };

  outputs = { self, clp_src, fzf_tmux_kak, nixpkgs, zig-overlay, zls }:
    let
    	pkgs = nixpkgs.legacyPackages.x86_64-linux;

    	clp = pkgs.stdenv.mkDerivation
    	{
        name = "clp";
        src = clp_src;
        buildInputs = [ pkgs.pkg-config pkgs.luajit pkgs.luajitPackages.lpeg pkgs.luajitPackages.luautf8 ];
    	};
      
    in {
      devShells.x86_64-linux.default =
        pkgs.mkShell.override { stdenv = pkgs.llvmPackages_15.stdenv; } {
          name = "Dev env";

          zig = zig-overlay.packages.x86_64-linux.master;

          gccwrap = ./bin;
          kakrc = ./config/kak;
          kak_lsp_cfg = ./config/kak-lsp/kak-lsp.toml;
          kak_fzf = fzf_tmux_kak;

          shellHook = ''
            export ENV_NAME="kak"
            export KAKOUNE_CONFIG_DIR="$kakrc"
            # export OCAMLPARAM="verbose=1,_"
            export PATH=$PATH:$clp/bin:$gccwrap:$zig/bin:$zls/bin
            export EDITOR=kak
          '';

      	  inputsFrom = [ clp ];

          buildInputs = [
            pkgs.zsh

            pkgs.fzf
            pkgs.fd
            pkgs.zsh

            pkgs.kakoune
            pkgs.kak-lsp
            pkgs.nil

            pkgs.libxml2.dev

            pkgs.cloc

            pkgs.nodejs
            pkgs.nodePackages.typescript-language-server
            pkgs.tree-sitter
            pkgs.llvmPackages_15.llvm
            pkgs.llvmPackages_15.llvm.dev
            pkgs.llvmPackages_15.lld
            pkgs.llvmPackages_15.lldb
            pkgs.llvmPackages_15.libclang
            pkgs.llvmPackages_15.libcxx
            pkgs.llvmPackages_15.libcxx.dev


            (pkgs.ccls.override {
              stdenv = pkgs.llvmPackages_15.stdenv;
            })

            pkgs.cmake
            pkgs.m4

            clp
          ];
        };
    };
}
