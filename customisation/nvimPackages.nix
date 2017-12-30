{ pkgs, lib, ... }:

# customisation for nix packages
let nvim = pkgs.neovim.override {
             vimAlias = true;
#             viAlias = true; # 17.09 doesn't have this, yet
	     configure = {
	       customRC = let vimrc = builtins.readFile ./init.vim;
	                  in ''${vimrc}'';
	     };
           };
in with pkgs; 
   [ nvim
     vimPlugins.vim-nix
     vimPlugins.ghc-mod-vim
     vimPlugins.haskell-vim
     vimPlugins.stylish-haskell
     vimPlugins.Hoogle
     vimPlugins.pathogen
     vimPlugins.Supertab
     vimPlugins.vim-addon-nix
     vimPlugins.airline
   ]
