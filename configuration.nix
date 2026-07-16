# configuration.nix
############################################################
#
# System Configuration & Dotfiles (Ultimate Unixporn Adaptation)
#
############################################################

{ config, pkgs, lib, ... }:

let
  # --- Binary Paths ---
  rofiBin = "${pkgs.rofi}/bin/rofi";
  kittyBin = "${pkgs.kitty}/bin/kitty";
  tmuxBin = "${pkgs.tmux}/bin/tmux";
  firefoxBin = "${pkgs.firefox}/bin/firefox";
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
  xssLockBin = "${pkgs.xss-lock}/bin/xss-lock";
  picomBin = "${pkgs.picom}/bin/picom";
  gamescopeBin = "${pkgs.gamescope}/bin/gamescope";
  steamBin = "${pkgs.steam}/bin/steam";
  clipmenuBin = "${pkgs.clipmenu}/bin/clipmenu";
  pythonBin = "${pkgs.python3}/bin/python3";
  jqBin = "${pkgs.jq}/bin/jq";
  lazygitBin = "${pkgs.lazygit}/bin/lazygit";
  ncspotBin = "${pkgs.ncspot}/bin/ncspot";
  nvimBin = "${pkgs.neovim}/bin/nvim";
  fehBin = "${pkgs.feh}/bin/feh";

  # --- Custom Scripts ---
  # Adapted Rofi: Large icons, heavy padding, rounded corners, pure black
  rofiMenuScript = pkgs.writeShellScriptBin "rofi-menu" ''
    exec ${rofiBin} -show drun -show-icons -font "Monocraft 10" -icon-theme "Papirus-Dark" \
      -drun-display-format "{name}" -disable-history -hide-scrollbar \
      -theme-str 'window { background-color: #000000cc; border: 2px; border-color: #1e2030; border-radius: 12px; padding: 20px; width: 30%; }' \
      -theme-str 'mainbox { background-color: #00000000; spacing: 10px; }' \
      -theme-str 'inputbar { background-color: #1e203066; text-color: #cad3f5; padding: 15px; border-radius: 8px; children: [prompt,entry]; }' \
      -theme-str 'prompt { text-color: #8aadf4; padding: 0px 10px 0px 0px; }' \
      -theme-str 'entry { text-color: #cad3f5; placeholder: "Search..."; }' \
      -theme-str 'listview { background-color: #00000000; columns: 1; lines: 6; spacing: 4px; cycle: true; dynamic: true; layout: vertical; }' \
      -theme-str 'element { background-color: #00000000; text-color: #7f849c; padding: 12px; border-radius: 8px; orientation: horizontal; }' \
      -theme-str 'element selected { background-color: #31324466; text-color: #cad3f5; }' \
      -theme-str 'element-icon { size: 40px; margin: 0px 10px 0px 0px; background-color: transparent; }' \
      -theme-str 'element-text { vertical-align: 0.5; background-color: transparent; text-color: inherit; }'
  '';
  rofiMenuBin = "${rofiMenuScript}/bin/rofi-menu";

  # Rofi Keybind Cheatsheet
  showKeysScript = pkgs.writeShellScriptBin "show-keys" ''
    ${rofiBin} -dmenu -i -p "Keybinds" -font "Monocraft 10" -theme-str 'window {width: 35%; background-color: #000000cc; border: 2px; border-color: #1e2030; border-radius: 12px; padding: 20px;} entry {padding: 15px;}' <<EOF
    Super + Space       App Launcher
    Super + Enter       Terminal
    Super + Q           Kill Window
    Super + W           Browser (Firefox)
    Super + E           File Manager (Yazi)
    Super + N           Neovim IDE
    Super + R           Resize Mode
    Super + T           Tabbed Layout
    Super + F           Fullscreen
    Super + A           Terminal Scratchpad
    Super + S           Python REPL Scratchpad
    Super + D           System Monitor (btop)
    Super + G           Git TUI (Lazygit)
    Super + V           Clipboard History
    Super + C           Calculator
    Super + X           Lock Screen
    Super + Shift+N     Network Manager (nmtui)
    Super + H/J/K/L     Focus Window
    Super + Shift+H/J/K/L Move Window
    Super + , / .       Switch Monitor
    EOF
  '';
  showKeysBin = "${showKeysScript}/bin/show-keys";

  powerMenuScript = pkgs.writeShellScriptBin "power-menu" ''
    options="Lock\nSuspend\nReboot\nPoweroff\nLogout"
    selected=$(echo -e "$options" | ${rofiBin} -dmenu -p "Power" -font "Monocraft 10" -theme-str 'window {width: 15%; background-color: #000000cc; border: 2px; border-color: #1e2030; border-radius: 12px; padding: 20px;} entry {padding: 15px; placeholder: "Select...";}')
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
    ${xsetrootBin} -solid "#000000"
    ${pkgs.scrot}/bin/scrot /tmp/lock.png
    ${pkgs.imagemagick}/bin/convert /tmp/lock.png -blur 0x5 -resize 1920x1080 /tmp/lock.png
    ${i3lockBin} -i /tmp/lock.png --insidecolor=000000ff --ringcolor=8aadf4ff --line-uses-inside --keyhlcolor=cad3f5ff --bshlcolor=ed8796ff --separator-color=00000000 --insidevercolor=f5a97fff --ringvercolor=ed8796ff --insidewrongcolor=ed8796ff --ringwrongcolor=ed8796ff --verif-color=cad3f5ff --wrong-color=cad3f5ff --time-color=cad3f5ff --date-color=a5adcbff --layout-color=a5adcbff --radius=20 --ring-width=4 --ignore-empty-password --show-failed-attempts
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

  # Wallpaper Setter (Reads from /etc/nixos/wallpaper.png)
  setWallpaperScript = pkgs.writeShellScriptBin "set-wallpaper" ''
    WP_FILE="/etc/nixos/wallpaper.png"
    if [ -f "$WP_FILE" ]; then
      ${fehBin} --bg-fill "$WP_FILE"
    else
      ${xsetrootBin} -solid "#000000"
    fi
  '';
  setWallpaperBin = "${setWallpaperScript}/bin/set-wallpaper";
in
{
  imports = [ ./hardware-configuration.nix ];

  ############################################################
  # Boot & Kernel (Gaming Optimized)
  ############################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.consoleMode = "max";

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
    MANGOHUD = "1";
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

  # Mouse settings: No acceleration, 0 sensitivity
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    videoDrivers = [ "amdgpu" ];
    autoRepeatDelay = 650;
    autoRepeatInterval = 50;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3status i3lock-color autotiling ];
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

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [ libva-vdpau-driver libvdpau-va-gl ];
  programs.steam.enable = true;

  ############################################################
  # Tmux (Fixed NixOS Module with Auto-Restore)
  ############################################################
  programs.tmux = {
    enable = true;
    shortcut = "Space";
    baseIndex = 1;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [ resurrect continuum ];
    extraConfig = ''
      set -g mouse on
      set -g renumber-windows on
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
      set -g status-bg "#000000"
      set -g status-fg "#cad3f5"
      set -g status-justify centre
      set -g status-left "#[fg=#8aadf4,bold] #S "
      set -g status-right "#[fg=#a5adcb,bold] %Y-%m-%d  %H:%M "
      set -g window-status-current-format "#[fg=#000000,bg=#8aadf4,bold] #I:#W "
      set -g window-status-format "#[fg=#a5adcb,dim] #I:#W "

      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'
    '';
  };

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
  # Ly Display Manager (Riced)
  ############################################################
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      clock = "%c";
      numlock = true;
      hide_borders = false;
      bg = 0;     # Pure Black
      fg = 15;    # White
      border_fg = 4; # Blue
    };
  };
  services.displayManager.defaultSession = "none+i3";

  # --- Picom (Premium Frosted Glass & Rounded Corners) ---
  environment.etc."xdg/picom.conf".text = ''
    backend = "glx";
    vsync = true;
    use-damage = true;
    corner-radius = 12;
    shadow = true;
    shadow-radius = 15;
    shadow-opacity = 0.5;
    shadow-offset-x = -5;
    shadow-offset-y = -5;
    shadow-exclude = [ "class_g = 'dmenu'", "class_g = 'Rofi'", "name = 'i3lock'" ];
    fading = true;
    fade-in-step = 0.05;
    fade-out-step = 0.05;
    blur-method = "dual_kawase";
    blur-strength = 8;
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

  # --- Fastfetch ---
  environment.etc."xdg/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": { "source": "nixos", "padding": { "top": 1, "left": 1, "right": 3 } },
      "display": { "separator": " -> ", "color": { "keys": "4" } },
      "modules": [ "title", "separator", "os", "kernel", "uptime", "packages", "shell", "display", "de", "wm", "theme", "icons", "terminal", "cpu", "gpu", "memory", "swap", "disk", "localip", "locale" ]
    }
  '';

  # --- Neovim IDE (Fixed Neovim 0.11+ LSP API & Mason) ---
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

    vim.g.mapleader = " "

    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
      })
    end
    vim.opt.rtp:prepend(lazypath)

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
      { "windwp/nvim-autopairs" },
    })

    vim.cmd.colorscheme "catppuccin-macchiato"

    vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})
    vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
    vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, {})
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {})

    -- Modern Neovim 0.11+ LSP Setup
    require("mason").setup()
    require("mason-lspconfig").setup({
      automatic_enable = true
    })

    vim.lsp.config("*", {
      capabilities = require('cmp_nvim_lsp').default_capabilities()
    })

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

  # --- Dunst (Adapted from provided dotfiles) ---
  environment.etc."xdg/dunst/dunstrc".text = ''
    [global]
    follow = mouse
    width = 350
    offset = 10x40
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 400
    indicate_hidden = yes
    shrink = no
    separator_height = 2
    padding = 15
    horizontal_padding = 15
    text_icon_padding = 15
    frame_width = 2
    frame_color = "#1e2030"
    separator_color = frame
    sort = yes
    idle_threshold = 120
    font = Monocraft 10
    line_height = 0
    markup = full
    format = "<span weight='bold'>%s</span>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    word_wrap = yes
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    min_icon_size = 0
    max_icon_size = 32
    sticky_history = yes
    history_length = 20
    always_run_script = true
    title = Dunst
    class = Dunst
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    mouse_left_click = do_action, close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all
    
    [urgency_low]
    background = "#000000AA"
    foreground = "#cad3f5"
    timeout = 10
    
    [urgency_normal]
    background = "#000000AA"
    foreground = "#cad3f5"
    timeout = 10
    
    [urgency_critical]
    background = "#000000AA"
    foreground = "#ed8796"
    frame_color = "#ed8796"
    timeout = 0
    format = "<b>%s</b>\n%b"
  '';

  # --- Kitty (Adapted with exact 16 colors & block cursor) ---
  environment.etc."xdg/kitty/kitty.conf".text = ''
    font_family      Monocraft
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    
    symbol_map U+E000-U+F8FF JetBrainsMono Nerd Font
    
    font_size 11.0
    cursor_shape block
    cursor_blink_interval 0.5
    window_padding_width 10
    confirm_os_window_close 0
    
    foreground              #CDD6F4
    background              #000000
    selection_foreground    #000000
    selection_background    #8aadf4
    url_color               #89B4FA
    url_style               dashed
    cursor                  #F5E0DC
    cursor_text_color       #000000
    active_border_color     #8aadf4
    inactive_border_color   #1e2030
    
    background_opacity 0.90
    
    tab_bar_edge top
    tab_bar_style powerline
    tab_powerline_style slanted
    active_tab_foreground   #000000
    active_tab_background   #8aadf4
    inactive_tab_foreground #CDD6F4
    inactive_tab_background #1e2030

    # The 16 terminal colors
    color0  #45475A
    color8  #585B70
    color1  #F38BA8
    color9  #F38BA8
    color2  #A6E3A1
    color10 #A6E3A1
    color3  #F9E2AF
    color11 #F9E2AF
    color4  #89B4FA
    color12 #89B4FA
    color5  #F5C2E7
    color13 #F5C2E7
    color6  #94E2D5
    color14 #94E2D5
    color7  #BAC2DE
    color15 #A6ADC8
  '';

  # --- i3 Window Manager (Premium Gaps & Borders) ---
  environment.etc."xdg/i3/config".text = ''
    # ============================================================
    # Variables & Binaries
    # ============================================================
    set $mod Mod4
    set $term ${kittyBin} --single-instance -e ${tmuxBin} new -A -s main
    set $menu ${rofiMenuBin}
    set $browser ${firefoxBin}
    set $files ${kittyBin} --single-instance -e ${yaziBin}
    
    # ============================================================
    # Appearance (Premium Unixporn Gaps)
    # ============================================================
    font pango:Monocraft 10
    default_border pixel 2
    default_floating_border pixel 2
    smart_borders on
    smart_gaps on
    gaps inner 8
    gaps outer 4
    
    set $bg #000000
    set $fg #cad3f5
    set $accent #8aadf4
    set $inactive #1e2030
    set $urgent #ed8796
    
    client.focused          $accent   $accent   $bg       $accent   $accent
    client.focused_inactive $inactive $inactive $fg       $inactive $inactive
    client.unfocused        $bg       $bg       #a5adcb   $bg       $bg
    client.urgent           $urgent   $urgent   $fg       $urgent   $urgent
    client.placeholder      $bg       $bg       $fg       $bg       $bg
    
    # ============================================================
    # Monitors
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
    for_window [class="scratch_vim"] floating enable, resize set 1000 600, move position center
    for_window [class="scratch_nmtui"] floating enable, resize set 800 600, move position center
    
    # ============================================================
    # Core Apps (Left Hand)
    # ============================================================
    bindsym $mod+Return exec $term
    bindsym $mod+space exec --no-startup-id $menu
    bindsym $mod+q kill
    bindsym $mod+w exec $browser
    bindsym $mod+e exec $files
    bindsym $mod+f fullscreen toggle
    bindsym $mod+t layout toggle tabbed split
    
    # ============================================================
    # Window Focus (Right Hand Vim)
    # ============================================================
    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right
    
    # ============================================================
    # Window Movement (Right Hand Vim)
    # ============================================================
    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right
    
    # ============================================================
    # Workspaces & Monitors
    # ============================================================
    set $ws1 "1: DEV"
    set $ws2 "2: WEB"
    set $ws3 "3: TERM"
    set $ws4 "4: GAME"
    set $ws5 "5: CHAT"
    set $ws6 "6: DOC"
    set $ws7 "7: GIT"
    set $ws8 "8: VM"
    set $ws9 "9: MON"
    set $ws10 "10: MISC"
    
    workspace $ws1 output DisplayPort-0
    workspace $ws2 output DisplayPort-0
    workspace $ws3 output DisplayPort-0
    workspace $ws4 output DisplayPort-0
    workspace $ws5 output DisplayPort-0
    workspace $ws6 output DisplayPort-0
    workspace $ws7 output DisplayPort-0
    workspace $ws8 output DisplayPort-0
    workspace $ws9 output DisplayPort-0
    workspace $ws10 output HDMI-A-0
    
    assign [class="firefox"] $ws2
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
    bindsym $mod+0 workspace number $ws10
    
    bindsym $mod+Shift+1 move container to workspace number $ws1
    bindsym $mod+Shift+2 move container to workspace number $ws2
    bindsym $mod+Shift+3 move container to workspace number $ws3
    bindsym $mod+Shift+4 move container to workspace number $ws4
    bindsym $mod+Shift+5 move container to workspace number $ws5
    bindsym $mod+Shift+6 move container to workspace number $ws6
    bindsym $mod+Shift+7 move container to workspace number $ws7
    bindsym $mod+Shift+8 move container to workspace number $ws8
    bindsym $mod+Shift+9 move container to workspace number $ws9
    bindsym $mod+Shift+0 move container to workspace number $ws10
    
    # Monitor Focus (Right Hand)
    bindsym $mod+comma workspace back_and_forth
    bindsym $mod+period move workspace to output right
    
    # ============================================================
    # Scratchpads & Utilities (Left Hand)
    # ============================================================
    bindsym $mod+a exec --no-startup-id ${scratchTermBin}
    bindsym $mod+s exec --no-startup-id ${scratchPythonBin}
    bindsym $mod+d exec --no-startup-id ${scratchBtopBin}
    bindsym $mod+g exec --no-startup-id ${kittyBin} --class=scratch_git -e ${lazygitBin}
    bindsym $mod+n exec --no-startup-id ${kittyBin} --class=scratch_vim -e ${nvimBin}
    bindsym $mod+m exec --no-startup-id ${kittyBin} --class=scratch_music -e ${ncspotBin}
    bindsym $mod+v exec --no-startup-id ${clipmenuBin}
    bindsym $mod+c exec --no-startup-id ${rofiBin} -show calc -modi calc -plugin-path ${pkgs.rofi-calc}/lib/rofi
    bindsym $mod+x exec --no-startup-id ${lockBin}
    bindsym $mod+F1 exec --no-startup-id ${showKeysBin}
    
    # Network Manager TUI
    bindsym $mod+Shift+n exec --no-startup-id ${kittyBin} --class=scratch_nmtui -e ${nmtuiBin}
    
    # ============================================================
    # Resize Mode
    # ============================================================
    bindsym $mod+r mode "resize"
    mode "resize" {
        bindsym h resize shrink width 10 px or 10 ppt
        bindsym j resize grow height 10 px or 10 ppt
        bindsym k resize shrink height 10 px or 10 ppt
        bindsym l resize grow width 10 px or 10 ppt
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    
    # ============================================================
    # System & Media Keys
    # ============================================================
    bindsym $mod+Escape exec --no-startup-id ${powerMenuBin}
    bindsym $mod+Shift+p exec --no-startup-id ${powerMenuBin}
    
    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindsym XF86AudioPlay exec --no-startup-id ${playerctlBin} play-pause
    bindsym XF86AudioNext exec --no-startup-id ${playerctlBin} next
    bindsym XF86AudioPrev exec --no-startup-id ${playerctlBin} previous
    
    bindsym Print exec ${flameshotBin} full -c
    bindsym $mod+Shift+s exec ${flameshotBin} gui
    
    # ============================================================
    # Autostart (Stripped for < 1GB RAM)
    # ============================================================
    exec --no-startup-id ${xssLockBin} --transfer-sleep-lock -- ${lockBin} --nofork
    exec --no-startup-id ${dunstBin} -config /etc/xdg/dunst/dunstrc
    exec --no-startup-id ${setWallpaperBin}
    exec --no-startup-id ${picomBin} --config /etc/xdg/picom.conf
    exec --no-startup-id /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1
    exec --no-startup-id clipmenud
    exec --no-startup-id autotiling
    exec --no-startup-id ${flameshotBin}
    
    # ============================================================
    # Status Bar (Minimal Style)
    # ============================================================
    bar {
            status_command ${i3statusBin} -c /etc/xdg/i3status.conf
            position bottom
            font pango:Monocraft 10
            tray_output primary
            workspace_buttons yes
            colors {
                    background #000000
                    statusline #cad3f5
                    separator  #1e2030
                    focused_workspace  #8aadf4 #8aadf4 #000000
                    active_workspace   #1e2030 #1e2030 #cad3f5
                    inactive_workspace #000000 #000000 #a5adcb
                    urgent_workspace   #ed8796 #ed8796 #000000
                    binding_mode       #ed8796 #ed8796 #000000
            }
    }
    
    # Reload & Restart
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+r restart
  '';

  # --- i3status Config (Minimal Style) ---
  environment.etc."xdg/i3status.conf".text = ''
    general {
      colors = true
      interval = 2
      color_good = "#a6da95"
      color_degraded = "#eed49f"
      color_bad = "#ed8796"
      separator = "  "
    }
    order += "disk /"
    order += "cpu_usage"
    order += "memory"
    order += "volume master"
    order += "tztime local"
    disk / { format = " 󰋊 %used / %total " }
    cpu_usage { format = " 󰻠 %usage " }
    memory { format = " 󰍛 %used / %total " threshold_degraded = "10%" format_degraded = " 󰍛 LOW %available " }
    volume master { format = " 󰕾 %volume " format_muted = " 󰖁 MUTE " device = "pulse" }
    tztime local { format = " 󰃰 %Y-%m-%d  %H:%M " }
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
    btop fastfetch htop libva-utils lsof mesa-demos ncdu pciutils radeontop strace tree usbutils vulkan-tools killall scrot imagemagick xclip xsel yazi libqalculate chafa

    # --- Gaming ---
    corectrl dxvk gamescope lutris mangohud protonup-qt vinegar vkbasalt wineWowPackages.stable winetricks noriskclient-launcher

    # --- Desktop & GUI ---
    adwaita-qt brightnessctl clipmenu discord dunst feh firefox flameshot gnome-themes-extra i3 i3lock-color kitty papirus-icon-theme pavucontrol picom playerctl polkit_gnome qutebrowser rofi rofi-emoji rofi-calc spotify vesktop xdotool xss-lock ncspot

    # --- Custom Scripts ---
    rofiMenuScript lockScript scratchTermScript scratchPythonScript scratchBtopScript setWallpaperScript powerMenuScript showKeysScript
  ];

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05";
  ## v18.0
}
