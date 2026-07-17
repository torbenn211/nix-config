# configuration.nix
############################################################
#
# NixOS Developer Workstation (Kasane Teto Theme)
#
############################################################

{ config, pkgs, lib, ... }:

let
  # --- Binary Paths ---
  rofiBin = "${pkgs.rofi}/bin/rofi";
  kittyBin = "${pkgs.kitty}/bin/kitty";
  firefoxBin = "${pkgs.firefox}/bin/firefox";
  vesktopBin = "${pkgs.vesktop}/bin/vesktop";
  yaziBin = "${pkgs.yazi}/bin/yazi";
  btopBin = "${pkgs.btop}/bin/btop";
  flameshotBin = "${pkgs.flameshot}/bin/flameshot";
  playerctlBin = "${pkgs.playerctl}/bin/playerctl";
  xrandrBin = "${pkgs.xrandr}/bin/xrandr";
  i3lockBin = "${pkgs.i3lock-color}/bin/i3lock-color";
  i3Bin = "${pkgs.i3}/bin/i3-msg";
  picomBin = "${pkgs.picom}/bin/picom";
  polybarBin = "${pkgs.polybar}/bin/polybar";
  dunstBin = "${pkgs.dunst}/bin/dunst";
  clipmenuBin = "${pkgs.clipmenu}/bin/clipmenu";
  xssLockBin = "${pkgs.xss-lock}/bin/xss-lock";
  xsetrootBin = "${pkgs.xsetroot}/bin/xsetroot";
  fehBin = "${pkgs.feh}/bin/feh";
  curlBin = "${pkgs.curl}/bin/curl";
  mpvBin = "${pkgs.mpv}/bin/mpv";

  # --- Custom Scripts ---
  rofiMenuScript = pkgs.writeShellScriptBin "rofi-menu" ''
    exec ${rofiBin} -show drun -show-icons -font "JetBrainsMono Nerd Font 11" -icon-theme "Papirus-Dark" \
      -drun-display-format "{name}" -disable-history -hide-scrollbar \
      -theme-str 'window { background-color: #1A1A1A; border: 2px; border-color: #FF003C; border-radius: 4px; padding: 10px; width: 25%; }' \
      -theme-str 'mainbox { background-color: #1A1A1A; spacing: 0px; }' \
      -theme-str 'inputbar { background-color: #2A2A2A; text-color: #F8F8F2; padding: 10px; children: [prompt,entry]; }' \
      -theme-str 'prompt { text-color: #FF003C; padding: 0px 5px 0px 0px; }' \
      -theme-str 'entry { text-color: #F8F8F2; placeholder: "Search..."; }' \
      -theme-str 'listview { background-color: #1A1A1A; columns: 1; lines: 6; spacing: 2px; cycle: true; dynamic: true; layout: vertical; }' \
      -theme-str 'element { background-color: #1A1A1A; text-color: #6C7086; padding: 8px; border-radius: 2px; orientation: horizontal; }' \
      -theme-str 'element selected { background-color: #2A2A2A; text-color: #FF003C; }' \
      -theme-str 'element-icon { size: 24px; margin: 0px 8px 0px 0px; background-color: transparent; }' \
      -theme-str 'element-text { vertical-align: 0.5; background-color: transparent; text-color: inherit; }'
  '';
  rofiMenuBin = "${rofiMenuScript}/bin/rofi-menu";

  autostartScript = pkgs.writeShellScriptBin "dev-autostart" ''
    sleep 2
    ${i3Bin} "workspace 1; exec ${kittyBin}"
    ${i3Bin} "workspace 2; exec ${firefoxBin}"
    ${i3Bin} "workspace 3; exec ${vesktopBin}"
    ${i3Bin} "workspace 10; exec ${kittyBin} --class=monitor_btop -e ${btopBin}"
    ${i3Bin} "workspace 1"
  '';
  autostartBin = "${autostartScript}/bin/dev-autostart";

  # Intro Player Script
  playIntroScript = pkgs.writeShellScriptBin "play-intro" ''
    INTRO_DIR="$HOME/intro"
    mkdir -p "$INTRO_DIR"
    
    INTRO_FILE=$(find "$INTRO_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" -o -iname "*.mp3" -o -iname "*.wav" -o -iname "*.gif" \) | head -n 1)
    
    if [ -n "$INTRO_FILE" ]; then
      ${mpvBin} --fullscreen --no-border --osc=no --loop=none "$INTRO_FILE"
    fi
  '';
  playIntroBin = "${playIntroScript}/bin/play-intro";

  lockScript = pkgs.writeShellScriptBin "blur-lock" ''
    ${xsetrootBin} -solid "#1A1A1A"
    ${pkgs.scrot}/bin/scrot /tmp/lock.png
    ${pkgs.imagemagick}/bin/convert /tmp/lock.png -blur 0x5 -resize 1920x1080 /tmp/lock.png
    ${i3lockBin} -i /tmp/lock.png --insidecolor=1A1A1Aff --ringcolor=FF003Cff --line-uses-inside --keyhlcolor=F8F8F2ff --bshlcolor=FFD700ff --separator-color=00000000 --insidevercolor=1A1A1Aff --ringvercolor=FF003Cff --insidewrongcolor=1A1A1Aff --ringwrongcolor=FFD700ff --verif-color=F8F8F2ff --wrong-color=F8F8F2ff --time-color=F8F8F2ff --date-color=F8F8F2ff --layout-color=F8F8F2ff --radius=20 --ring-width=4 --ignore-empty-password --show-failed-attempts
    rm /tmp/lock.png
  '';
  lockBin = "${lockScript}/bin/blur-lock";

  powerMenuScript = pkgs.writeShellScriptBin "power-menu" ''
    options="Lock\nSuspend\nReboot\nPoweroff\nLogout"
    selected=$(echo -e "$options" | ${rofiBin} -dmenu -p "Power" -font "JetBrainsMono Nerd Font 11" -theme-str 'window {width: 15%; background-color: #1A1A1A; border: 2px; border-color: #FF003C; border-radius: 4px; padding: 10px;} entry {padding: 10px; placeholder: "Select...";}')
    case "$selected" in
      Lock) ${lockBin} ;;
      Suspend) systemctl suspend ;;
      Reboot) systemctl reboot ;;
      Poweroff) systemctl poweroff ;;
      Logout) i3-msg exit ;;
    esac
  '';
  powerMenuBin = "${powerMenuScript}/bin/power-menu";

  # Fetches a dark red abstract wallpaper from Unsplash if local one is missing
  setWallpaperScript = pkgs.writeShellScriptBin "set-wallpaper" ''
    WP_DIR="$HOME/.local/share"
    WP_FILE="$WP_DIR/wallpaper.jpg"
    mkdir -p "$WP_DIR"
    if [ ! -f "$WP_FILE" ]; then
      ${curlBin} -sL "https://images.unsplash.com/photo-1610040123105-1da3aae19a92?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80" -o "$WP_FILE"
    fi
    if [ -f "$WP_FILE" ]; then
      ${fehBin} --bg-fill "$WP_FILE"
    else
      ${xsetrootBin} -solid "#1A1A1A"
    fi
  '';
  setWallpaperBin = "${setWallpaperScript}/bin/set-wallpaper";
in
{
  imports = [ ./hardware-configuration.nix ];

  # --- Boot & Kernel (Performance Optimized) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
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

  # --- System Optimizations ---
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
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  security.pam.loginLimits = [
    { domain = "@wheel"; item = "rtprio"; type = "-"; value = 99; }
    { domain = "@wheel"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = 99; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  # --- Networking & Locale ---
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

  # --- Theming ---
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

  # --- Input ---
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
    };
  };

  # --- X11 & i3 ---
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    videoDrivers = [ "amdgpu" ];
    autoRepeatDelay = 300;
    autoRepeatInterval = 50;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3status i3lock-color autotiling ];
    };

    xkb = { layout = "de"; variant = ""; options = "caps:none"; };
    deviceSection = '' Option "TearFree" "true" '';
  };
  console.keyMap = "de";

  # --- Gaming & Hardware ---
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

  # --- Shell (Zsh & Modern CLI) ---
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellInit = ''
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      eval "$(${pkgs.starship}/bin/starship init zsh)"
      
      alias ls='${pkgs.eza}/bin/eza --icons --group-directories-first'
      alias cat='${pkgs.bat}/bin/bat --paging=never'
      alias cd='z'
      
      alias lg='${pkgs.lazygit}/bin/lazygit'
      alias gd='git diff'
      alias gs='git status'
      
      fastfetch
    '';
  };
  users.users."torbenn".shell = pkgs.zsh;
  environment.shellAliases = { rebuild = "sudo nixos-rebuild switch"; };

  # --- Display Manager ---
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      clock = "%c";
      numlock = true;
      hide_borders = false;
      bg = 0;
      fg = 15;
      border_fg = 1; # Red
    };
  };
  services.displayManager.defaultSession = "none+i3";

  # --- Compositor (Picom - Teto Aura & Anime Fade) ---
  environment.etc."xdg/picom.conf".text = ''
    backend = "glx";
    vsync = true;
    use-damage = true;
    corner-radius = 4;
    shadow = true;
    shadow-radius = 20;
    shadow-opacity = 0.6;
    shadow-offset-x = -5;
    shadow-offset-y = -5;
    shadow-exclude = [ "class_g = 'dmenu'", "class_g = 'Rofi'", "name = 'i3lock'" ];
    fading = true;
    fade-in-step = 0.02;
    fade-out-step = 0.02;
    
    blur-method = "dual_kawase";
    blur-strength = 10;
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
      "display": { "separator": " -> ", "color": { "keys": "1" } },
      "modules": [ "title", "separator", "os", "kernel", "uptime", "packages", "shell", "display", "de", "wm", "theme", "icons", "terminal", "cpu", "gpu", "memory", "swap", "disk", "localip", "locale" ]
    }
  '';

  # --- Neovim (IDE Configuration) ---
  environment.etc."xdg/nvim/init.lua".text = ''
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
      { "ThePrimeagen/harpoon" },
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" } },
      { "L3MON4D3/LuaSnip", dependencies = { "saadparwaiz1/cmp_luasnip" } },
      { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
      { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
      { "lewis6991/gitsigns.nvim" },
      { "akinsho/toggleterm.nvim", version = "*", config = true },
      { "windwp/nvim-autopairs" },
    })

    vim.cmd.colorscheme "catppuccin-macchiato"

    vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})
    vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
    vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, {})
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {})
    vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", {})
    vim.keymap.set("n", "<C-/>", ":ToggleTerm<CR>", {})

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

  # --- Dunst (Notifications - Teto Red/Black) ---
  environment.etc."xdg/dunst/dunstrc".text = ''
    [global]
    monitor = 0
    follow = mouse
    width = (250, 350)
    height = (50, 300)
    origin = top-right
    offset = 4x34
    scale = 0
    notification_limit = 0
    
    progress_bar = true
    progress_bar_height = 5
    progress_bar_frame_width = 0
    progress_bar_min_width = 200
    progress_bar_max_width = 350
    
    indicate_hidden = yes
    transparency = 20
    separator_height = 1
    padding = 10
    horizontal_padding = 8
    text_icon_padding = 10
    frame_width = 2
    frame_color = "#FF003C"
    separator_color = "#2A2A2A"
    sort = yes
    idle_threshold = 120
    
    font = JetBrainsMono Nerd Font Medium 11
    line_height = 0
    markup = full
    format = "<b>%a</b>\n%s\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = true
    show_indicators = yes
    
    icon_position = left
    min_icon_size = 32
    max_icon_size = 90
    icon_path = /run/current-system/sw/share/icons/Adwaita/16x16/mimetypes/:/run/current-system/sw/share/icons/Papirus-Dark/16x16/actions
    
    sticky_history = yes
    history_length = 20
    dmenu = ${pkgs.dmenu}/bin/dmenu -p dunst:
    browser = /run/current-system/sw/bin/xdg-open
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 0
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    
    mouse_left_click = do_action, close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all
    
    [urgency_low]
    background = "#1A1A1A"
    foreground = "#FF003C"
    timeout = 5
    
    [urgency_normal]
    background = "#1A1A1A"
    foreground = "#F8F8F2"
    timeout = 5
    
    [urgency_critical]
    background = "#1A1A1A"
    foreground = "#FFD700"
    frame_color = "#FFD700"
    timeout = 0
  '';

  # --- Kitty (Terminal - Teto Red/Black) ---
  environment.etc."xdg/kitty/kitty.conf".text = ''
    font_family      JetBrainsMono Nerd Font
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    font_size        12.0
    
    foreground              #F8F8F2
    background              #1A1A1A
    url_color               #FF003C
    cursor                  #F8F8F2
    
    term xterm-256color
    background_opacity 0.85
    
    tab_bar_edge top
    tab_bar_style powerline
    tab_bar_align left
    tab_powerline_style slanted
    tab_title_max_length 0
    
    active_tab_foreground   #1A1A1A
    active_tab_background   #FF003C
    active_tab_font_style   bold-italic
    inactive_tab_foreground #F8F8F2
    inactive_tab_background #2A2A2A
    inactive_tab_font_style normal
    
    scrollback_lines 10000
    window_border_width 2pt
    
    selection_background #4D4D4D
    selection_foreground #F8F8F2
    
    color0  #4D4D4D
    color8  #6A6A6A
    color1  #FF003C
    color9  #FF4D6D
    color2  #A6E3A1
    color10 #A6E3A1
    color3  #FFD700
    color11 #FFD700
    color4  #89B4FA
    color12 #89B4FA
    color5  #F5C2E7
    color13 #F5C2E7
    color6  #94E2D5
    color14 #94E2D5
    color7  #BFC7D5
    color15 #D4D8E8

    copy_on_select yes
    strip_trailing_spaces always
  '';

  # --- Polybar (Status Bar - Minimalist Teto) ---
  environment.etc."xdg/polybar/config.ini".text = ''
    [colors]
    background = #1A1A1A
    background-alt = #2A2A2A
    foreground = #F8F8F2
    primary = #FF003C
    secondary = #FF4D6D
    alert = #FFD700
    disabled = #6C7086

    [bar/main]
    width = 100%
    height = 20pt
    radius = 0
    background = #1A1A1A
    foreground = #F8F8F2
    line-size = 2pt
    border-size = 0pt
    border-color = #00000000
    padding-left = 1
    padding-right = 1
    module-margin = 1
    separator = |
    font-0 = "JetBrainsMono Nerd Font:weight=bold:size=10"
    modules-left = xworkspaces
    modules-center = date
    modules-right = cpu memory pulseaudio
    tray-position = right
    wm-restack = i3

    [module/date]
    type = internal/date
    interval = 1
    date = %H:%M | %a, %b %d
    label = %date%
    label-foreground = #FF003C

    [module/xworkspaces]
    type = internal/xworkspaces
    pin-workspaces = false
    label-active = " %index% "
    label-active-background = #FF003C
    label-active-foreground = #1A1A1A
    label-active-padding = 1
    label-occupied = " %index% "
    label-occupied-foreground = #F8F8F2
    label-occupied-padding = 1
    label-empty = " %index% "
    label-empty-foreground = #6C7086
    label-empty-padding = 1
    label-urgent = " %index% "
    label-urgent-foreground = #FFD700
    label-urgent-padding = 1

    [module/cpu]
    type = internal/cpu
    interval = 2
    format-prefix = "CPU "
    format-prefix-foreground = #FF003C
    label = %percentage:2%%

    [module/memory]
    type = internal/memory
    interval = 2
    format-prefix = "RAM "
    format-prefix-foreground = #FF4D6D
    label = %percentage_used%%

    [module/pulseaudio]
    type = internal/pulseaudio
    format-volume-prefix = "󰕾 "
    format-volume-prefix-foreground = #FF003C
    format-volume = <label-volume>
    label-volume = %percentage%%
    label-muted = 󰖁 Muted
    label-muted-foreground = #6C7086

    [settings]
    screenchange-reload = true
    pseudo-transparency = true
  '';

  # --- i3 Window Manager (Mouse Focus & Teto Theme) ---
  environment.etc."xdg/i3/config".text = ''
    set $mod Mod4
    set $term ${kittyBin}
    set $menu ${rofiMenuBin}
    set $browser ${firefoxBin}
    set $files ${kittyBin} -e ${yaziBin}
    
    font pango:JetBrainsMono Nerd Font 10
    default_border pixel 2
    default_floating_border pixel 2
    smart_borders on
    smart_gaps on
    gaps inner 6
    gaps outer 0
    
    # Dwindle simulation
    exec --no-startup-id ${pkgs.autotiling}/bin/autotiling
    
    # Focus behavior (Mouse focus enabled!)
    focus_follows_mouse yes
    mouse_warping output
    
    # Colors (Teto Red & Dark Grey)
    set $bg #1A1A1A
    set $fg #F8F8F2
    set $accent #FF003C
    set $inactive #2A2A2A
    set $urgent #FFD700
    
    client.focused          $accent   $accent   $bg       $accent   $accent
    client.focused_inactive $inactive $inactive $fg       $inactive $inactive
    client.unfocused        $bg       $bg       #6C7086   $bg       $bg
    client.urgent           $urgent   $urgent   $fg       $urgent   $urgent
    client.placeholder      $bg       $bg       $fg       $bg       $bg
    
    # --- Monitor Setup ---
    # Primary: DisplayPort-0 (180Hz), Secondary: HDMI-A-0 (75Hz)
    exec --no-startup-id ${xrandrBin} --output DisplayPort-0 --mode 1920x1080 --rate 180.00 --primary --output HDMI-A-0 --mode 1920x1080 --rate 74.97 --right-of DisplayPort-0
    
    # --- Window Rules ---
    for_window [class="Pavucontrol"] floating enable, resize set 800 600, move position center
    for_window [class="flameshot"] floating enable
    for_window [title="Picture-in-Picture"] floating enable, sticky enable
    for_window [window_role="pop-up"] floating enable, move position center
    for_window [window_type="dialog"] floating enable, move position center
    for_window [class="monitor_btop"] floating enable, resize set 1000 600, move position center
    for_window [class="mpv"] floating enable, resize set 1920 1080, move position center
    
    # --- Omarchy Core Binds ---
    bindsym $mod+space exec --no-startup-id $menu
    bindsym $mod+Return exec $term
    bindsym $mod+w kill
    bindsym $mod+Shift+Return exec $browser
    bindsym $mod+e exec $files
    bindsym $mod+v exec --no-startup-id ${clipmenuBin}
    bindsym $mod+p exec --no-startup-id ${powerMenuBin}
    
    # --- Window Management (Omarchy) ---
    bindsym $mod+t floating toggle
    bindsym $mod+f fullscreen toggle
    bindsym $mod+j split toggle
    bindsym $mod+l layout toggle split tabbed stacking
    
    # --- Focus (Omarchy Arrows) ---
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right
    
    # --- Movement (Omarchy Arrows) ---
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right
    
    # --- Workspaces (Omarchy Normal Layout) ---
    set $ws1 "1"
    set $ws2 "2"
    set $ws3 "3"
    set $ws4 "4"
    set $ws5 "5"
    set $ws6 "6"
    set $ws7 "7"
    set $ws8 "8"
    set $ws9 "9"
    set $ws10 "10"
    
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
    assign [class="Vesktop"] $ws3
    assign [class="Steam"] $ws5
    
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
    
    # --- Workspace Navigation ---
    bindsym $mod+Tab workspace next
    bindsym $mod+Shift+Tab workspace prev
    
    # --- Monitor Focus (Omarchy Right Hand) ---
    bindsym $mod+comma workspace back_and_forth
    bindsym $mod+period move workspace to output right
    
    # --- Scratchpads & Screenshot ---
    bindsym $mod+s scratchpad show
    bindsym $mod+Shift+s move scratchpad
    
    bindsym Print exec --no-startup-id ${flameshotBin} full -c
    bindsym $mod+Shift+x exec --no-startup-id ${flameshotBin} gui
    
    # --- Resize (Omarchy) ---
    bindsym $mod+equal resize shrink width 10 px or 10 ppt
    bindsym $mod+minus resize grow width 10 px or 10 ppt
    bindsym $mod+Shift+equal resize grow height 10 px or 10 ppt
    bindsym $mod+Shift+minus resize shrink height 10 px or 10 ppt
    
    # --- System & Media Keys ---
    bindsym $mod+Escape exec --no-startup-id ${powerMenuBin}
    bindsym $mod+Ctrl+l exec --no-startup-id ${lockBin}
    
    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindsym XF86AudioPlay exec --no-startup-id ${playerctlBin} play-pause
    bindsym XF86AudioNext exec --no-startup-id ${playerctlBin} next
    bindsym XF86AudioPrev exec --no-startup-id ${playerctlBin} previous
    
    # --- Autostart ---
    exec --no-startup-id ${xssLockBin} --transfer-sleep-lock -- ${lockBin}
    exec --no-startup-id ${dunstBin} -config /etc/xdg/dunst/dunstrc
    exec --no-startup-id ${setWallpaperBin}
    exec --no-startup-id ${picomBin} --config /etc/xdg/picom.conf
    exec --no-startup-id /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1
    # Play Intro Video on Login
    exec --no-startup-id ${playIntroBin}
    exec --no-startup-id ${autostartBin}
    
    # --- Status Bar ---
    exec_always --no-startup-id ${polybarBin} main
    
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+r restart
  '';

  # --- Audio ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true;
    pulse.enable = true; wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;

  hardware.bluetooth.enable = false;

  # --- Fonts ---
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # --- User ---
  users.users."torbenn" = {
    isNormalUser = true;
    description = "torbenn";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  nixpkgs.config.allowUnfree = true;

  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    # Development Core
    bat bun cargo clang cmake curl delta dotnet-sdk eza fd gcc gh git go jq fzf neovim ninja nodejs python3 python3Packages.pip ripgrep rustc unzip vscode wget xdg-utils yq zip lazygit zoxide direnv starship
    
    # CLI Utilities
    btop fastfetch htop libva-utils lsof mesa-demos ncdu pciutils radeontop strace tree usbutils vulkan-tools killall scrot imagemagick xclip xsel yazi libqalculate chafa openrgb
    
    # Gaming
    corectrl dxvk gamescope lutris mangohud protonup-qt vinegar vkbasalt wineWow64Packages.stable winetricks noriskclient-launcher
    
    # Desktop & GUI
    adwaita-qt brightnessctl clipmenu discord dunst feh firefox flameshot gnome-themes-extra i3 i3status i3lock-color kitty xsetroot xrandr papirus-icon-theme pavucontrol picom playerctl polkit_gnome polybar qutebrowser rofi rofi-emoji rofi-calc spotify vesktop xdotool xss-lock ncspot mpv
    
    # Custom Scripts
    rofiMenuScript lockScript autostartScript setWallpaperScript powerMenuScript playIntroScript
  ];

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # --- Maintenance ---
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05";
}
