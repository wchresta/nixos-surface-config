{ pkgs, lib, ... }:

# customisation for nix packages
let nvim = pkgs.neovim.override {
             vimAlias = true;
#             viAlias = true; # 17.09 doesn't have this, yet
	     configure = {
	       customRC = let vimrc = builtins.readFile ./init.vim;
	                  in ''
                             ${vimrc}
                             autocmd FileType hs :packadd haskell-vim
                             autocmd FileType hs :packadd ghc-mod-vim
                             autocmd FileType hs :packadd stylish-haskell
                             autocmd FileType hs :packadd Hoogle

                             autocmd FileType nix :packadd tlib
                             autocmd FileType nix :packadd vim-addon-actions
                             autocmd FileType nix :packadd vim-addon-mw-utils
                             autocmd FileType nix :packadd vim-nix
                             autocmd FileType nix :packadd vim-addon-nix
                             '';

               packages.myVimPackage = with pkgs.vimPlugins; {
                 start = [ Supertab 
                           airline 
                         ];
                 opt = [ ghc-mod-vim 
                         haskell-vim 
                         stylish-haskell
                         Hoogle

                         tlib # needed by vim-addon-nix
                         vim-addon-actions # needed by vim-addon-nix
                         vim-addon-mw-utils # needed by vim-addon-nix
                         vim-nix
                         vim-addon-nix
                       ];
               };
	     };
           };
in with pkgs; 
   [ nvim ]
