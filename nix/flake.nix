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
            ({ config, lib, pkgs, ... }: {
            home.username = "Diego.Rojas";
            home.homeDirectory = "/Users/Diego.Rojas";
            home.stateVersion = "24.05";

            programs.home-manager.enable = true;

            # Get my SSH keys from Bitwarden
            home.activation.setupSSHKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
              SSH_DIR="${config.home.homeDirectory}/.ssh"
              mkdir -p "$SSH_DIR"

              # Only do bw login if any of the exppected keys does not exists
              if [ ! -f "$SSH_DIR/id_ed25519" ] || [ ! -f "$SSH_DIR/gy_2025" ] || [ ! -f "$SSH_DIR/id_rsa_digital_ocean_multihub" ]; then
                BW="${pkgs.bitwarden-cli}/bin/bw"

                # Verify if it is logged in
                if ! $BW login --check >/dev/null 2>&1; then
                  echo -e "\033[0;31mWarning: Bitwarden not logged in. SSH keys won't be retrieved Run bw login and export the BW_SESSION.\033[0m"
                else
                  # Personal (id_ed25519)
                  if [ ! -f "$SSH_DIR/id_ed25519" ]; then
                    $BW get item "SSH - Personal" | ${pkgs.jq}/bin/jq -r '.notes' > "$SSH_DIR/id_ed25519"
                    chmod 600 "$SSH_DIR/id_ed25519"
                    ${pkgs.openssh}/bin/ssh-keygen -y -f "$SSH_DIR/id_ed25519" > "$SSH_DIR/id_ed25519.pub"
                    echo "✓ SSH key 'id_ed25519' created"
                  fi

                  # GoodYear (gy_2025)
                  if [ ! -f "$SSH_DIR/gy_2025" ]; then
                    $BW get item "SSH - GoodYear" | ${pkgs.jq}/bin/jq -r '.notes' > "$SSH_DIR/gy_2025"
                    chmod 600 "$SSH_DIR/gy_2025"
                    ${pkgs.openssh}/bin/ssh-keygen -y -f "$SSH_DIR/gy_2025" > "$SSH_DIR/gy_2025.pub"
                    echo "✓ SSH key 'gy_2025' created"
                  fi

                  # DigitalOcean (id_rsa_digital_ocean_multihub)
                  if [ ! -f "$SSH_DIR/id_rsa_digital_ocean_multihub" ]; then
                    $BW get item "SSH - DigitalOcean" | ${pkgs.jq}/bin/jq -r '.notes' > "$SSH_DIR/id_rsa_digital_ocean_multihub"
                    chmod 600 "$SSH_DIR/id_rsa_digital_ocean_multihub"
                    ${pkgs.openssh}/bin/ssh-keygen -y -f "$SSH_DIR/id_rsa_digital_ocean_multihub" > "$SSH_DIR/id_rsa_digital_ocean_multihub.pub"
                    echo "✓ SSH key 'id_rsa_digital_ocean_multihub' created"
                  fi
                fi
              fi
            '';

            # Bitwarden CLI
            home.packages = with pkgs; [
              bitwarden-cli
            ];

            # Create workdirs for code projects if does not exists
            home.activation.createWorkspaces = lib.hm.dag.entryAfter ["writeBoundary"] ''
              $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "${config.home.homeDirectory}/Documents/personal"
              $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "${config.home.homeDirectory}/Documents/work"
            '';

            # Manage Ghostty config file
            home.file."Library/Application Support/com.mitchellh.ghostty/config".text = ''
                bell-features = no-audio,no-system
                shell-integration = zsh
                keybind = super+d=new_split:down
                keybind = super+u=new_split:up
                keybind = super+r=new_split:right
                keybind = super+l=new_split:left
                keybind = shift+enter=text:\n
                theme = TokyoNight
            '';

            programs.gh = {
                enable = true;
                settings = {
                    git_protocol = "ssh";
                    editor = "nvim";
                };
            };

            programs.git = {
              enable = true;
              includes = [
                {
                  condition = "gitdir:~/Documents/personal/";
                  contents = {
                    user = {
                      email = "rojastorrado@gmail.com";
                      name = "Diego Fernando Rojas";
                    };
                    core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
                  };
                }
                {
                  condition = "gitdir:~/Documents/work/";
                  contents = {
                    user = {
                      email = "diego_rojas@goodyear.com";
                      name = "Diego Fernando Rojas";
                    };
                    core.sshCommand = "ssh -i ~/.ssh/gy_2025";
                  };
                }
              ];
            };

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
                    hm = "home-manager switch --flake ~/Documents/personal/opensource/config-files/nix#Diego.Rojas";
                    rs = "exec zsh";
                    bwu = "export BW_SESSION=$(bw unlock --raw)";
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
            })
        ];
        };
    };
}
