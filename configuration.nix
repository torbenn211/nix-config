# configuration.nix
############################################################
#
# System Configuration & Dotfiles (Ultimate Unixporn Edition)
#
############################################################

{ config, pkgs, lib, ... }:

let
  # --- Binary Paths ---
  rofiBin = "${pkgs.rofi}/bin/rofi";
  kittyBin = "${pkgs.kitty}/bin/kitty";
  tmuxBin = "${pkgs.tmux}/bin/tmux";
  qutebrowserBin = "${pkgs.qutebrowser}/bin/qutebrowser";
  yaziBin = "${pkgs.yazi}/bin/yazi";
  btopBin = "${pkgs.btop}/bin/btop";
  pavucontrolBin = "${pkgs.pavucontrol}/bin/pavucontrol";
  nmtuiBin = "${pkgs.networkmanager}/bin/nmtui";
  xrandrBin = "${pkgs.xrandr}/bin/xrandr";
  xdotoolBin = "${pkgs.xdotool}/bin/xdotool";
  i3lockBin = "${pkgs.i3lock-color}/bin/i3lock-color";
  i3statusBin = "${pkgs.i3status}/bin/i3status";
  flameshotBin = "${pkgs.flameshot}/bin/flameshot";
  playerctlBin = "${pkgs.playerctl}/bin/playerctl";
  brightnessctlBin = "${pkgs.brightnessctl}/bin/brightnessctl";
  xsetrootBin = "${pkgs.xsetroot}/bin/xsetroot";
  dunstBin = "${pkgs.dunst}/bin/dunst";
  dunstctlBin = "${pkgs.dunst}/bin/dunstctl";
  nmAppletBin = "${pkgs.networkmanagerapplet}/bin/nm-applet";
  dexBin = "${pkgs.dex}/bin/dex";
  xssLockBin = "${pkgs.xss-lock}/bin/xss-lock";
  picomBin = "${pkgs.picom}/bin/picom";
  gamescopeBin = "${pkgs.gamescope}/bin/gamescope";
  steamBin = "${pkgs.steam}/bin/steam";
  clipmenuBin = "${pkgs.clipmenu}/bin/clipmenu";
  rofiEmojiBin = "${pkgs.rofi-emoji}/bin/rofi-emoji";
  pythonBin = "${pkgs.python3}/bin/python3";
  jqBin = "${pkgs.jq}/bin/jq";
  fehBin = "${pkgs.feh}/bin/feh";
  curlBin = "${pkgs.curl}/bin/curl";
  conkyBin = "${pkgs.conky}/bin/conky";
  lazygitBin = "${pkgs.lazygit}/bin/lazygit";
  ncspotBin = "${pkgs.ncspot}/bin/ncspot";

  # --- Custom Scripts ---
  rofiMenuScript = pkgs.writeShellScriptBin "rofi-menu" ''
    exec ${rofiBin} -show drun -show-icons -font "JetBrainsMono Nerd Font 10" -icon-theme "Papirus-Dark" \
      -drun-display-format "{name}" -disable-history -hide-scrollbar \
      -theme-str 'window { background-color: #24273a; border: 2px; border-color: #363a4f; border-radius: 8px; padding: 12px; width: 30%; }' \
      -theme-str 'mainbox { background-color: #24273a; spacing: 0px; }' \
      -theme-str 'inputbar { background-color: #1e2030; text-color: #cad3f5; padding: 12px; border: 0px 0px 2px 0px; border-color: #363a4f; }' \
      -theme-str 'prompt { text-color: #8aadf4; }' \
      -theme-str 'entry { text-color: #cad3f5; placeholder: "Search..."; }' \
      -theme-str 'listview { background-color: #24273a; columns: 1; lines: 8; spacing: 4px; cycle: true; dynamic: true; layout: vertical; }' \
      -theme-str 'element { background-color: #24273a; text-color: #a5adcb; padding: 8px; border-radius: 4px; orientation: horizontal; }' \
      -theme-str 'element selected { background-color: #363a4f; text-color: #cad3f5; }' \
      -theme-str 'element-icon { size: 24px; margin: 0px 10px 0px 0px; }' \
      -theme-str 'element-text { vertical-align: 0.5; }'
  '';
  rofiMenuBin = "${rofiMenuScript}/bin/rofi-menu";

  # Rofi Keybind Cheatsheet
  showKeysScript = pkgs.writeShellScriptBin "show-keys" ''
    ${rofiBin} -dmenu -i -p "Keybinds" -theme-str 'window {width: 40%;}' <<EOF
    Super + Enter       Terminal
    Super + Shift + Enter Browser
    Super + D           App Launcher
    Super + N           File Manager (Yazi)
    Super + W           Kill Window
    Super + Z           Terminal Scratchpad
    Super + P           Python REPL Scratchpad
    Super + M           System Monitor (btop)
    Super + G           Git TUI (Lazygit)
    Super + O           Jump to Monitor 2
    Super + F1          Show this menu
    Super + F11         Lock Screen
    Super + Shift + P   Power Menu
    EOF
  '';
  showKeysBin = "${showKeysScript}/bin/show-keys";

  powerMenuScript = pkgs.writeShellScriptBin "power-menu" ''
    options="Lock\nSuspend\nReboot\nPoweroff\nLogout"
    selected=$(echo -e "$options" | ${rofiBin} -dmenu -p "Power" -theme-str 'window {width: 15%;} entry {placeholder: "Select...";}')
    case "$selected" in
      Lock) ${lockBin} ;;
      Suspend) systemctl suspend ;;
      Reboot) systemctl reboot ;;
      Poweroff) systemctl poweroff ;;
      Logout) i3-msg exit ;;
    esac
  '';
  powerMenuBin = "${powerMenuScript}/bin/power-menu";

  lockScript = pkgs.writeShellScriptBin "blur-lock" ''
    ${xsetrootBin} -solid "#24273a"
    ${pkgs.scrot}/bin/scrot /tmp/lock.png
    ${pkgs.imagemagick}/bin/convert /tmp/lock.png -blur 0x5 -resize 1920x1080 /tmp/lock.png
    ${i3lockBin} -i /tmp/lock.png --insidecolor=24273aff --ringcolor=8aadf4ff --line-uses-inside --keyhlcolor=cad3f5ff --bshlcolor=ed8796ff --separator-color=00000000 --insidevercolor=f5a97fff --ringvercolor=ed8796ff --insidewrongcolor=ed8796ff --ringwrongcolor=ed8796ff --verif-color=cad3f5ff --wrong-color=cad3f5ff --time-color=cad3f5ff --date-color=a5adcbff --layout-color=a5adcbff --radius=20 --ring-width=4 --ignore-empty-password --show-failed-attempts
    rm /tmp/lock.png
  '';
  lockBin = "${lockScript}/bin/blur-lock";

  # Scratchpad Toggles
  scratchTermScript = pkgs.writeShellScriptBin "scratch-term" ''
    if [ $(${i3statusBin} -t get_tree | ${jqBin} -r '.nodes[].nodes[].nodes[].window_properties.class' | grep -c "scratch_term") -gt 0 ]; then
      i3-msg "[class=\"scratch_term\"] scratchpad show"
    else
      ${kittyBin} --class=scratch_term -e ${tmuxBin} new -A -s scratch
    fi
  '';
  scratchTermBin = "${scratchTermScript}/bin/scratch-term";

  scratchPythonScript = pkgs.writeShellScriptBin "scratch-python" ''
    if [ $(${i3statusBin} -t get_tree | ${jqBin} -r '.nodes[].nodes[].nodes[].window_properties.class' | grep -c "scratch_python") -gt 0 ]; then
      i3-msg "[class=\"scratch_python\"] scratchpad show"
    else
      ${kittyBin} --class=scratch_python -e ${pythonBin}
    fi
  '';
  scratchPythonBin = "${scratchPythonScript}/bin/scratch-python";

  scratchBtopScript = pkgs.writeShellScriptBin "scratch-btop" ''
    if [ $(${i3statusBin} -t get_tree | ${jqBin} -r '.nodes[].nodes[].nodes[].window_properties.class' | grep -c "scratch_btop") -gt 0 ]; then
      i3-msg "[class=\"scratch_btop\"] scratchpad show"
    else
      ${kittyBin} --class=scratch_btop -e ${btopBin}
    fi
  '';
  scratchBtopBin = "${scratchBtopScript}/bin/scratch-btop";

  setWallpaperScript = pkgs.writeShellScriptBin "set-wallpaper" ''
    WP_DIR="$HOME/.local/share"
    WP_FILE="$WP_DIR/wallpaper.jpg"
    mkdir -p "$WP_DIR"
    if [ ! -f "$WP_FILE" ]; then
      ${curlBin} -sL "https://wallpapercave.com/wp/wp6600355.jpg" -o "$WP_FILE"
    fi
    ${fehBin} --bg-fill "$WP_FILE"
  '';
  setWallpaperBin = "${setWallpaperScript}/bin/set-wallpaper";
in
{
  imports = [ ./hardware-configuration.nix ];

  ############################################################
  # Boot & Kernel (Gaming Optimized & Riced)
  ############################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.consoleMode = "max"; # Riced boot resolution

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ 
    "amdgpu.ppfeaturemask=0xffffffff" 
    "amdgpu.performance_level=high" 
    "mitigations=off"
    "nowatchdog"
    "split_lock_detect=off"
    "preempt=full"
  ];

  boot.kernelModules = [ "tcp_bbr" "amdgpu" ];
  boot.tmp.cleanOnBoot = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.min_free_kbytes" = 262144;
    "vm.watermark_boost_factor" = 0;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;

  services.scx = {
    enable = true;
    scheduler = "scx_bpfland";
  };

  hardware.ksm.enable = true;
  zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 100; };
  services.fstrim.enable = true;
  
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.daemonIOSchedClass = "idle";
  nix.daemonCPUSchedPolicy = "idle";
  
  programs.command-not-found.enable = false;
  documentation.nixos.enable = false;
  services.dbus.implementation = "broker";

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    WINEESYNC = "1";
    WINEFSYNC = "1";
    XCURSOR_SIZE = "32";
    MANGOHUD = "1"; # Auto-enable mangohud for all games
  };

  security.pam.loginLimits = [
    { domain = "@wheel"; item = "rtprio"; type = "-"; value = 99; }
    { domain = "@wheel"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = 99; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8"; LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8"; LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8"; LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8"; LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "adwaita-dark";
  };

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Catppuccin-Macchiato-Standard-Blue-Dark
    gtk-application-prefer-dark-theme=1
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Adwaita
    gtk-cursor-theme-size=32
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-icon-theme-name=Papirus-Dark
  '';

  services.libinput = {
    enable = true;
    mouse = { accelProfile = "flat"; accelSpeed = "-0.3"; };
  };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    videoDrivers = [ "amdgpu" ];
    autoRepeatDelay = 650;
    autoRepeatInterval = 50;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3status i3lock-color ];
    };

    xkb = { layout = "de"; variant = ""; options = "caps:none"; };
    deviceSection = '' Option "TearFree" "true" '';
  };
  console.keyMap = "de";

  programs.gamemode = {
    enable = true;
    settings = {
      general = { renice = 10; softrealtime = "on"; inhibit_screensaver = 1; };
      cpu = { gov = "performance"; };
      gpu = { amd_performance_level = "high"; };
    };
  };

  programs.coolercontrol.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [ libva-vdpau-driver libvdpau-va-gl ];
  programs.steam.enable = true;

  ############################################################
  # Zsh & Starship (Developer Shell)
  ############################################################
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellInit = "eval \"$(${pkgs.starship}/bin/starship init zsh)\"";
  };
  users.users."torbenn".shell = pkgs.zsh;
  environment.shellAliases = { rebuild = "sudo nixos-rebuild switch"; };

  programs.bash.interactiveShellInit = ''
    if [ -z "$TMUX" ]; then
      fastfetch
    fi
  '';

  ############################################################
  # Ly Display Manager (Riced & Fixed)
  ############################################################
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      clock = "%c";
      numlock = true;
      hide_borders = false;
      bg = 8;     # Dark Blue/Black
      fg = 15;    # White
      border_fg = 4; # Blue
    };
  };
  # Fixed: defaultSession must be set here, not inside ly.settings
  services.displayManager.defaultSession = "none+i3";

  # --- Picom (Premium Frosted Glass) ---
  environment.etc."xdg/picom.conf".text = ''
    backend = "glx";
    vsync = true;
    use-damage = true;
    corner-radius = 8;
    shadow = true;
    shadow-radius = 12;
    shadow-opacity = 0.4;
    shadow-offset-x = -4;
    shadow-offset-y = -4;
    shadow-exclude = [ "class_g = 'dmenu'", "class_g = 'Rofi'", "name = 'i3lock'" ];
    fading = true;
    fade-in-step = 0.05;
    fade-out-step = 0.05;
    blur-method = "dual_kawase";
    blur-strength = 5;
    blur-background = true;
    blur-background-frame = true;
    blur-background-exclude = [
        "window_type = 'desktop'",
        "class_g = 'Rofi'",
        "class_g = 'dmenu'",
        "name = 'i3lock'"
    ];
    inactive-opacity = 0.95;
    inactive-dim = 0.1;
    focus-exclude = [ "class_g = 'Rofi'", "class_g = 'dmenu'", "name = 'i3lock'" ];
    unredir-if-possible = true;
    unredir-if-possible-exclude = [];
  '';

  # --- Conky ---
  environment.etc."xdg/conky/conky.conf".text = ''
    conky.config = {
        alignment = 'top_right',
        background = false,
        border_width = 1,
        cpu_avg_samples = 2,
        default_color = '#cad3f5',
        default_outline_color = 'white',
        default_shade_color = 'white',
        double_buffer = true,
        draw_borders = false,
        draw_graph_borders = true,
        draw_outline = false,
        draw_shades = false,
        extra_newline = false,
        font = 'JetBrainsMono Nerd Font:size=10',
        gap_x = 20,
        gap_y = 60,
        minimum_height = 5,
        minimum_width = 200,
        net_avg_samples = 2,
        no_buffers = true,
        out_to_console = false,
        out_to_ncurses = false,
        out_to_stderr = false,
        out_to_x = true,
        own_window = true,
        own_window_class = 'Conky',
        own_window_type = 'desktop',
        own_window_transparent = true,
        own_window_argb_visual = true,
        show_graph_range = true,
        show_graph_scale = false,
        stippled_borders = 0,
        update_interval = 2.0,
        uppercase = false,
        use_spacer = 'none',
        use_xft = true,
        xftalpha = 0.1,
    }
    conky.text = [[
    ''${color #8aadf4}System:''${color} $sysname $kernel
    ''${color #8aadf4}Uptime:''${color} $uptime
    ''${color #8aadf4}CPU:''${color} ''${cpu cpu0}% ''${cpubar cpu0}
    ''${color #8aadf4}RAM:''${color} $mem/$memmax ''${membar}
    ''${color #8aadf4}Disk:''${color} ''${fs_used /}/''${fs_size /} ''${fs_bar /}
    ]]
  '';

  # --- Fastfetch ---
  environment.etc."xdg/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": { "source": "nixos", "padding": { "top": 1, "left": 1, "right": 3 } },
      "display": { "separator": " -> ", "color": { "keys": "4" } },
      "modules": [ "title", "separator", "os", "kernel", "uptime", "packages", "shell", "display", "de", "wm", "theme", "icons", "terminal", "cpu", "gpu", "memory", "swap", "disk", "localip", "locale" ]
    }
  '';

  # --- Neovim IDE (init.lua with Mason) ---
  environment.etc."xdg/nvim/init.lua".text = ''
    -- Basic Settings
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    vim.opt.expandtab = true
    vim.opt.smartindent = true
    vim.opt.termguicolors = true
    vim.opt.wrap = false

    -- Leader Key
    vim.g.mapleader = " "

    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
      })
    end
    vim.opt.rtp:prepend(lazypath)

    -- Plugins
    require("lazy").setup({
      { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      { "nvim-telescope/telescope.nvim", tag = "0.1.5", dependencies = { "nvim-lua/plenary.nvim" } },
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" } },
      { "L3MON4D3/LuaSnip", dependencies = { "saadparwaiz1/cmp_luasnip" } },
      { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
      { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
      { "tpope/vim-fugitive" },
      { "windwp/nvim-autopairs" },
    })

    -- Theme
    vim.cmd.colorscheme "catppuccin-macchiato"

    -- Keybindings
    vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})
    vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
    vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, {})
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {})

    -- LSP Config (Mason handles installation)
    require("mason").setup()
    require("mason-lspconfig").setup()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require('lspconfig')
    lspconfig.clangd.setup { capabilities = capabilities }
    lspconfig.pyright.setup { capabilities = capabilities }
    lspconfig.rust_analyzer.setup { capabilities = capabilities }
    lspconfig.ts_ls.setup { capabilities = capabilities }
    lspconfig.gopls.setup { capabilities = capabilities }

    -- Autocompletion
    local cmp = require'cmp'
    cmp.setup({
      snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
      })
    })
  '';

  # --- Dunst ---
  environment.etc."xdg/dunst/dunstrc".text = ''
    [global]
    monitor = 0
    follow = keyboard
    geometry = "400x5-30+30"
    transparency = 10
    corner_radius = 8
    font = JetBrainsMono Nerd Font 10
    frame_color = "#363a4f"
    separator_color = frame
    progress_bar_corner_radius = 4
    
    [urgency_low]
    background = "#24273a"
    foreground = "#cad3f5"
    timeout = 5
    
    [urgency_normal]
    background = "#24273a"
    foreground = "#cad3f5"
    timeout = 10
    
    [urgency_critical]
    background = "#ed8796"
    foreground = "#24273a"
    timeout = 0
  '';

  # --- Tmux ---
  environment.etc."tmux.conf".text = ''
    set -g prefix C-Space
    unbind C-b
    bind C-Space send-prefix
    set -g mouse on
    set -g base-index 1
    setw -g pane-base-index 1
    set -g renumber-windows on
    set -g default-terminal "tmux-256color"
    set -ga terminal-overrides ",xterm-256color:Tc"
    
    bind q source-file /etc/tmux.conf \; display "Config Reloaded!"
    bind v split-window -h -c "#{pane_current_path}"
    bind h split-window -v -c "#{pane_current_path}"
    
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D
    
    bind -n M-1 select-window -t 1
    bind -n M-2 select-window -t 2
    bind -n M-3 select-window -t 3
    bind -n M-4 select-window -t 4
    bind -n M-5 select-window -t 5
    bind -n M-6 select-window -t 6
    bind -n M-7 select-window -t 7
    bind -n M-8 select-window -t 8
    bind -n M-9 select-window -t 9
    
    set -g status-position bottom
    set -g status-bg "#24273a"
    set -g status-fg "#cad3f5"
    set -g status-justify centre
    set -g status-left "#[fg=#8aadf4,bold] #S "
    set -g status-right "#[fg=#a5adcb,bold] %Y-%m-%d  %H:%M "
    set -g window-status-current-format "#[fg=#24273a,bg=#8aadf4,bold] #I:#W "
    set -g window-status-format "#[fg=#a5adcb,dim] #I:#W "
  '';

  # --- Kitty ---
  environment.etc."xdg/kitty/kitty.conf".text = ''
    font_family JetBrainsMono Nerd Font
    font_size 10.0
    cursor_shape beam
    cursor_blink_interval 0.5
    window_padding_width 6
    
    foreground              #cad3f5
    background              #24273a
    selection_foreground    #24273a
    selection_background    #8aadf4
    url_color               #f5a97f
    active_border_color     #8aadf4
    inactive_border_color   #363a4f
    
    background_opacity 0.95
    
    tab_bar_edge top
    tab_bar_style powerline
    tab_powerline_style slanted
    active_tab_foreground   #24273a
    active_tab_background   #8aadf4
    inactive_tab_foreground #a5adcb
    inactive_tab_background #363a4f
  '';

  # --- i3 Window Manager ---
  environment.etc."xdg/i3/config".text = ''
    # ============================================================
    # Variables & Binaries
    # ============================================================
    set $mod Mod4
    set $term ${kittyBin} --single-instance -e ${tmuxBin} new -A -s main
    set $menu ${rofiMenuBin}
    set $browser ${qutebrowserBin}
    set $files ${kittyBin} --single-instance -e ${yaziBin}
    
    # ============================================================
    # Appearance
    # ============================================================
    font pango:JetBrainsMono Nerd Font 10
    default_border pixel 3
    default_floating_border pixel 3
    smart_borders on
    smart_gaps on
    gaps inner 8
    gaps outer 0
    
    set $bg #24273a
    set $fg #cad3f5
    set $accent #8aadf4
    set $inactive #363a4f
    set $urgent #ed8796
    
    client.focused          $accent   $accent   $bg       $accent   $accent
    client.focused_inactive $inactive $inactive $fg       $inactive $inactive
    client.unfocused        $bg       $bg       #a5adcb   $bg       $bg
    client.urgent           $urgent   $urgent   $fg       $urgent   $urgent
    client.placeholder      $bg       $bg       $fg       $bg       $bg
    
    # ============================================================
    # Monitors (1-9 on Primary, Special key for Secondary)
    # ============================================================
    exec --no-startup-id ${xrandrBin} --output DisplayPort-0 --mode 1920x1080 --rate 180.00 --primary --output HDMI-A-0 --mode 1920x1080 --rate 74.97 --right-of DisplayPort-0
    
    # ============================================================
    # Window Rules
    # ============================================================
    for_window [class="Pavucontrol"] floating enable, resize set 800 600, move position center
    for_window [class="flameshot"] floating enable
    for_window [title="Picture-in-Picture"] floating enable, sticky enable
    for_window [window_role="pop-up"] floating enable, move position center
    for_window [window_type="dialog"] floating enable, move position center
    for_window [class="scratch_term"] floating enable, resize set 1000 600, move position center
    for_window [class="scratch_python"] floating enable, resize set 800 600, move position center
    for_window [class="scratch_btop"] floating enable, resize set 1000 600, move position center
    for_window [class="scratch_git"] floating enable, resize set 1000 600, move position center
    for_window [class="scratch_music"] floating enable, resize set 1000 600, move position center
    
    # ============================================================
    # Core Binds
    # ============================================================
    bindsym $mod+Return exec $term
    bindsym $mod+d exec --no-startup-id $menu
    bindsym $mod+Shift+Return exec $browser
    bindsym $mod+n exec $files
    bindsym $mod+w kill
    
    bindsym $mod+v split v
    bindsym $mod+b split h
    bindsym $mod+e layout toggle split
    bindsym $mod+t layout tabbed
    bindsym $mod+s layout stacking
    bindsym $mod+f fullscreen toggle
    bindsym $mod+Shift+space floating toggle
    bindsym $mod+space focus mode_toggle
    
    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right
    
    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right
    
    # Workspaces (1-9 Primary)
    set $ws1 "1: DEV"
    set $ws2 "2: WEB"
    set $ws3 "3: TERM"
    set $ws4 "4: GAME"
    set $ws5 "5: CHAT"
    set $ws6 "6: MISC"
    set $ws7 "7"
    set $ws8 "8"
    set $ws9 "9"
    
    workspace $ws1 output DisplayPort-0
    workspace $ws2 output DisplayPort-0
    workspace $ws3 output DisplayPort-0
    workspace $ws4 output DisplayPort-0
    workspace $ws5 output DisplayPort-0
    workspace $ws6 output DisplayPort-0
    workspace $ws7 output DisplayPort-0
    workspace $ws8 output DisplayPort-0
    workspace $ws9 output DisplayPort-0
    
    workspace "10: MON2" output HDMI-A-0
    
    assign [class="qutebrowser"] $ws2
    assign [class="Steam"] $ws4
    assign [class="discord"] $ws5
    assign [class="Vesktop"] $ws5
    
    bindsym $mod+1 workspace number $ws1
    bindsym $mod+2 workspace number $ws2
    bindsym $mod+3 workspace number $ws3
    bindsym $mod+4 workspace number $ws4
    bindsym $mod+5 workspace number $ws5
    bindsym $mod+6 workspace number $ws6
    bindsym $mod+7 workspace number $ws7
    bindsym $mod+8 workspace number $ws8
    bindsym $mod+9 workspace number $ws9
    
    bindsym $mod+Shift+1 move container to workspace number $ws1
    bindsym $mod+Shift+2 move container to workspace number $ws2
    bindsym $mod+Shift+3 move container to workspace number $ws3
    bindsym $mod+Shift+4 move container to workspace number $ws4
    bindsym $mod+Shift+5 move container to workspace number $ws5
    bindsym $mod+Shift+6 move container to workspace number $ws6
    bindsym $mod+Shift+7 move container to workspace number $ws7
    bindsym $mod+Shift+8 move container to workspace number $ws8
    bindsym $mod+Shift+9 move container to workspace number $ws9
    
    bindsym $mod+Tab workspace next
    bindsym $mod+Shift+Tab workspace prev
    
    # ============================================================
    # Scratchpads & Utilities
    # ============================================================
    bindsym $mod+z exec --no-startup-id ${scratchTermBin}
    bindsym $mod+p exec --no-startup-id ${scratchPythonBin}
    bindsym $mod+m exec --no-startup-id ${scratchBtopBin}
    bindsym $mod+g exec --no-startup-id ${kittyBin} --class=scratch_git -e ${lazygitBin}
    bindsym $mod+Shift+m exec --no-startup-id ${kittyBin} --class=scratch_music -e ${ncspotBin}
    bindsym $mod+Shift+d exec --no-startup-id ${clipmenuBin}
    bindsym $mod+slash exec --no-startup-id ${rofiEmojiBin}
    bindsym $mod+period exec --no-startup-id ${rofiBin} -show calc -modi calc -plugin-path ${pkgs.rofi-calc}/lib/rofi
    bindsym $mod+Shift+p exec --no-startup-id ${powerMenuBin}
    
    # Rofi Keybind Cheatsheet
    bindsym $mod+F1 exec --no-startup-id ${showKeysBin}
    
    # Special Monitor 2 Keybind
    bindsym $mod+o workspace "10: MON2"
    bindsym $mod+Shift+o move container to workspace "10: MON2"
    
    # System & Media
    bindsym $mod+Escape exec --no-startup-id ${powerMenuBin}
    bindsym $mod+F11 exec --no-startup-id ${lockBin}
    bindsym $mod+Ctrl+l exec --no-startup-id ${lockBin}
    
    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindsym XF86AudioPlay exec --no-startup-id ${playerctlBin} play-pause
    bindsym XF86AudioNext exec --no-startup-id ${playerctlBin} next
    bindsym XF86AudioPrev exec --no-startup-id ${playerctlBin} previous
    
    bindsym Print exec ${flameshotBin} full -c
    bindsym $mod+Shift+s exec ${flameshotBin} gui
    
    # Autostart
    exec --no-startup-id ${dexBin} --autostart --environment i3
    exec --no-startup-id ${xssLockBin} --transfer-sleep-lock -- ${lockBin} --nofork
    exec --no-startup-id ${nmAppletBin}
    exec --no-startup-id ${dunstBin} -config /etc/xdg/dunst/dunstrc
    exec --no-startup-id ${setWallpaperBin}
    exec --no-startup-id ${picomBin} --config /etc/xdg/picom.conf
    exec --no-startup-id ${conkyBin} -c /etc/xdg/conky/conky.conf
    exec --no-startup-id /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1
    exec --no-startup-id clipmenud
    exec --no-startup-id udiskie -t
    
    # Status Bar
    bar {
            status_command ${i3statusBin} -c /etc/xdg/i3status.conf
            position bottom
            font pango:JetBrainsMono Nerd Font 10
            tray_output primary
            workspace_buttons yes
            colors {
                    background #24273a
                    statusline #cad3f5
                    separator  #363a4f
                    focused_workspace  #8aadf4 #8aadf4 #24273a
                    active_workspace   #363a4f #363a4f #cad3f5
                    inactive_workspace #24273a #24273a #a5adcb
                    urgent_workspace   #ed8796 #ed8796 #24273a
                    binding_mode       #ed8796 #ed8796 #24273a
            }
    }
  '';

  # --- i3status Config ---
  environment.etc."xdg/i3status.conf".text = ''
    general {
      colors = true
      interval = 5
      color_good = "#a6da95"
      color_degraded = "#eed49f"
      color_bad = "#ed8796"
      separator = " | "
    }
    order += "disk /"
    order += "cpu_usage"
    order += "memory"
    order += "volume master"
    order += "tztime local"
    disk / { format = "DISK %used / %total" }
    cpu_usage { format = "CPU %usage" }
    memory { format = "RAM %used / %total" threshold_degraded = "10%" format_degraded = "RAM LOW %available" }
    volume master { format = "VOL %volume" format_muted = "VOL MUTE" device = "pulse" }
    tztime local { format = "%Y-%m-%d %H:%M" }
  '';

  ############################################################
  # Audio (PipeWire)
  ############################################################
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true;
    pulse.enable = true; wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;

  hardware.bluetooth.enable = false;

  # Fixed: Renamed nerdfonts to nerd-fonts.jetbrains-mono
  fonts.packages = with pkgs; [
    monocraft
    nerd-fonts.jetbrains-mono
  ];

  users.users."torbenn" = {
    isNormalUser = true;
    description = "torbenn";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # --- Development ---
    bat bun cargo clang cmake curl dotnet-sdk eza fd gcc gh git jq fzf neovim ninja nodejs python3 python3Packages.pip ripgrep rustc tmux unzip vscode wget xdg-utils yq zip lazygit lazydocker zsh starship

    # --- CLI / TUI Utilities ---
    btop fastfetch htop libva-utils lsof mesa-demos ncdu pciutils radeontop strace tree usbutils vulkan-tools killall scrot imagemagick xclip xsel yazi libqalculate chafa udiskie

    # --- Gaming ---
    corectrl dxvk gamescope lutris mangohud protonup-qt vinegar vkbasalt wineWowPackages.stable winetricks noriskclient-launcher

    # --- Desktop & GUI (Minimal) ---
    adwaita-qt brightnessctl clipmenu conky dex discord dunst feh flameshot gnome-themes-extra i3 i3lock-color kitty networkmanagerapplet papirus-icon-theme pavucontrol picom playerctl polkit_gnome qutebrowser rofi rofi-emoji rofi-calc spotify vesktop xdotool xss-lock ncspot

    # --- Custom Scripts ---
    rofiMenuScript lockScript scratchTermScript scratchPythonScript scratchBtopScript setWallpaperScript powerMenuScript showKeysScript
  ];

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  ############################################################
  # Nix Auto Garbage Collection (Changed to 3 days)
  ############################################################
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05";
  ## v9.2
}
