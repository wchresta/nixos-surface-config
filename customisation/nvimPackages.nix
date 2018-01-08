{ pkgs, lib, ... }:

# customisation for nix packages
let nvim = pkgs.neovim.override {
            vimAlias = true;
#            viAlias = true; # 17.09 doesn't have this, yet
            configure = {
              customRC = let vimrc = builtins.readFile ./init.vim;
                         in ''colorscheme gruvbox
                              ${vimrc}'';

              vam = {
                knownPlugins = pkgs.vimPlugins;
                pluginDictionaries = [
                  # load always
                  { names = [ "gruvbox"
                              "airline" 
                              "Supertab"
                            ]; 
                  }
                  # load on nix config files
                  { filename_regex = "^\\.nix\$"; 
                    names = [ "vim-nix"
                              "vim-addon-nix"
                            ]; 
                  }
                  # load on Haskell files
                  { ft_regex = "^haskell\$"; 
                    names = [ "vimproc-vim"
                              "ghc-mod-vim"
                              "haskell-vim"
                              "stylish-haskell"
                              "Hoogle" 
                            ];
                  }
                ];
              };
            };
          };
in with pkgs; 
   [ nvim ]
