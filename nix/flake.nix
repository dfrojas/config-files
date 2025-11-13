# Claude Code has to be installed manually.
# Ghostty has to be installed manually.

{
 description = "Diego's Home Manager configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixvim = {
        url = "github:nix-community/nixvim";
        inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { nixpkgs, home-manager, nixvim, ... }: {
        homeConfigurations."Diego.Rojas" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;

        modules = [
            nixvim.homeModules.nixvim
            {
            home.username = "Diego.Rojas";
            home.homeDirectory = "/Users/Diego.Rojas";
            home.stateVersion = "24.05";

            programs.home-manager.enable = true;

            # Manage Ghostty config file
            home.file."Library/Application Support/com.mitchellh.ghostty/config".text = ''
                bell-features = no-audio,no-system
                shell-integration = zsh
                keybind = super+d=new_split:down
                keybind = super+u=new_split:up
                keybind = super+r=new_split:right
                keybind = super+l=new_split:left
            '';

            programs.zsh = {
                enable = true;
                enableCompletion = true;
                oh-my-zsh = {
                enable = true;
                theme = "robbyrussell";
                plugins = [
                    "git"
                    "docker"
                    "kubectl"
                ];
                };
                shellAliases = {
                    hm = "home-manager switch --flake ~/Documents/opensource/config-files/nix#Diego.Rojas";
                    rs = "exec zsh";
                };
                initExtra = ''
                    export PATH="$HOME/.local/bin:$PATH"
                    # PROMPT='%2~ %# '
                    PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%2~%{$reset_color%}"
                    PROMPT+=' $(git_prompt_info)'
                '';
            };
            programs.nixvim = {
                enable = true;
                globals.mapleader = " "; # Change the mapleader to Space
                colorschemes.tokyonight.enable = true;
                extraConfigVim = ''
                " Hide Airline sections Y and Z completely
                let g:airline_section_z = ""
                let g:airline_section_y = ""
                let g:airline_skip_empty_sections = 1
                '';
                opts = {
                    number = true;
                    clipboard = "unnamedplus";
                    laststatus = 2;
                    tabstop = 4;        # Number of spaces a tab counts for
                    shiftwidth = 4;     # Number of spaces for each indentation level
                    expandtab = true;   # Convert tabs to spaces
                    softtabstop = 4;    # Number of spaces for tab in insert mode
                };
                autoCmd = [{
                    event = ["BufWritePre"];
                    pattern = ["*"];
                    command = "%s/\\s\\+$//e";
                }];
                plugins = {
                    web-devicons.enable = true;
                    telescope = {
                        enable = true;
                    };
                    nvim-tree = {
                        enable = true;
                    };
                    airline = {
                        enable = true;
                        settings = {
                            powerline_fonts = true;
                            theme = "dark";
                        };
                    };
                    fugitive.enable = true;
                    lsp = {
                        enable = true;
                        servers = {
                            pyright.enable = true;
                            clangd.enable = true;
                            # rust_analyzer.enable = true;
                            gopls.enable = true;
                        };
                    };
                    # Syntax highlighting
                    treesitter = {
                        enable = true;
                        settings = {
                            highlight.enable = true;
                            indent.enable = true;
                        };
                    };
                    cmp = {
                        enable = true;
                        settings = {
                            sources = [
                                { name = "nvim_lsp"; }
                                { name = "path"; }
                                { name = "buffer"; }
                            ];
                        };
                    };
                };
                keymaps = [
                {
                    mode = "n";
                    key = "<leader>e";
                    action = ":NvimTreeToggle<CR>";
                    options = {
                    silent = true;
                    desc = "Toggle file tree";
                    };
                }
                {
                    mode = "n";
                    key = "<leader>ff";
                    action = ":Telescope find_files<CR>";
                    options = {
                    silent = true;
                    desc = "Find files";
                    };
                }
                {
                    mode = "n";
                    key = "<leader>fg";
                    action = ":Telescope live_grep<CR>";
                    options = {
                    silent = true;
                    desc = "Search in files";
                    };
                }
                {
                    mode = "n";
                    key = "<leader>h";
                    action = "<C-w>h";
                    options = {
                        silent = true;
                        desc = "Move Neovim to left pane from the tree to the code";
                    };
                }
                {
                    mode = "n";
                    key = "<leader>l";
                    action = "<C-w>l";
                    options = {
                        silent = true;
                        desc = "Move to right pane from the tree to the code";
                    };
                }
                {
                    mode = "n";
                    key = "gd";
                    action = "<cmd>lua vim.lsp.buf.definition()<CR>";
                    options = {
                        silent = true;
                        desc = "Go to definition";
                    };
                }
                {
                    mode = "n";
                    key = "<leader>gd";
                    action = "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>";
                    options = {
                        silent = true;
                        desc = "Go to definition";
                    };
                }
                ];
            };
            }
        ];
        };
    };
}
