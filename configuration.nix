# configuration.nix
############################################################
#
# System Configuration
#
############################################################
# This is the master configuration file for your NixOS system.
# It defines everything from your boot loader to your desktop environment,
# software, and dotfiles. Everything is contained in this one file.

{ config, pkgs, lib, ... }:

let
  # Define absolute paths to binaries. This is the Nix way to ensure
  # scripts and window managers always find the right executables.
  rofiBin = "${pkgs.rofi}/bin/rofi";
  kittyBin = "${pkgs.kitty}/bin/kitty";
  tmuxBin = "${pkgs.tmux}/bin/tmux";
  firefoxBin = "${pkgs.firefox}/bin/firefox";
  thunarBin = "${pkgs.thunar}/bin/thunar";
  btopBin = "${pkgs.btop}/bin/btop";
  pavucontrolBin = "${pkgs.pavucontrol}/bin/pavucontrol";
  nmtuiBin = "${pkgs.networkmanager}/bin/nmtui";
  xrandrBin = "${pkgs.xrandr}/bin/xrandr";
  xdotoolBin = "${pkgs.xdotool}/bin/xdotool";
  i3lockBin = "${pkgs.i3lock}/bin/i3lock";
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

  # Custom Rofi wrapper script defined inline so we can inject its absolute path
  # directly into i3, bypassing any $PATH issues.
  rofiMenuScript = pkgs.writeShellScriptBin "rofi-menu" ''
    exec ${rofiBin} -show drun -show-icons -font "Monocraft 10" -icon-theme "Papirus-Dark" \
      -drun-display-format "{name}" -disable-history -hide-scrollbar \
      -theme-str 'window { background-color: #000000; border: 2px; border-color: #333333; padding: 12px; width: 30%; }' \
      -theme-str 'mainbox { background-color: #000000; spacing: 0px; }' \
      -theme-str 'inputbar { background-color: #1A1A1A; text-color: #FFFFFF; padding: 10px; border: 0px 0px 2px 0px; border-color: #333333; }' \
      -theme-str 'prompt { text-color: #888888; }' \
      -theme-str 'entry { text-color: #FFFFFF; placeholder: "Search..."; }' \
      -theme-str 'listview { background-color: #000000; columns: 1; lines: 8; spacing: 4px; cycle: true; dynamic: true; layout: vertical; }' \
      -theme-str 'element { background-color: #000000; text-color: #888888; padding: 8px; border-radius: 0px; orientation: horizontal; }' \
      -theme-str 'element selected { background-color: #333333; text-color: #FFFFFF; }' \
      -theme-str 'element-icon { size: 20px; margin: 0px 10px 0px 0px; }' \
      -theme-str 'element-text { vertical-align: 0.5; }'
  '';
  rofiMenuBin = "${rofiMenuScript}/bin/rofi-menu";
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  ############################################################
  #
  # Boot & Kernel (Deep-Search Gaming Optimized)
  #
  ############################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1; # Speeds up boot process

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Unlocks AMD GPU power profiles, forces amdgpu to high performance, disables CPU security mitigations,
  # disables kernel watchdog (saves CPU), fixes Wine split_lock micro-stutters, and forces full kernel preemption for low latency.
  boot.kernelParams = [ 
    "amdgpu.ppfeaturemask=0xffffffff" 
    "amdgpu.performance_level=high" 
    "mitigations=off"
    "nowatchdog"
    "split_lock_detect=off"
    "preempt=full"
  ];

  # Add tcp_bbr for lower network latency
  boot.kernelModules = [ "tcp_bbr" "amdgpu" ];

  # Advanced: Cleans /tmp on every boot to prevent junk buildup.
  boot.tmp.cleanOnBoot = true;

  # Kernel Sysctl Tuning: Aggressive RAM/Cache/Network management for gaming.
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

  ############################################################
  #
  # Advanced System Optimizations (Reddit Gold)
  #
  ############################################################
  # KSM (Kernel Same-page Merging): Saves RAM by merging identical memory pages.
  hardware.ksm.enable = true;

  # ZRAM: Compresses RAM memory instead of using the swap file.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  # SSD Optimization: Runs a weekly TRIM to keep your SSD fast and healthy.
  services.fstrim.enable = true;

  # Journal Limits: Prevents system logs from eating up your disk space.
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';

  # Nix Flakes: Enables modern Nix command and Flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Nix Daemon Tuning: Background Nix builds run at lowest CPU priority so they never stutter your games.
  nix.daemonIOSchedClass = "idle";
  nix.daemonCPUSchedPolicy = "idle";

  # RAM Saver: Disables the massive NixOS package database background service
  programs.command-not-found.enable = false;

  # RAM Saver: Disables building and storing system manuals in memory
  documentation.nixos.enable = false;

  # RAM & CPU Saver: Replaces legacy D-Bus with a high-performance implementation
  services.dbus.implementation = "broker";

  ############################################################
  #
  # Environment Variables (FPS Boosts & Cursor Fix)
  #
  ############################################################
  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    WINEESYNC = "1";
    WINEFSYNC = "1";
    XCURSOR_SIZE = "32";
  };

  ############################################################
  #
  # Real-Time Process Priorities (PAM Limits)
  #
  ############################################################
  security.pam.loginLimits = [
    { domain = "@wheel"; item = "rtprio"; type = "-"; value = 99; }
    { domain = "@wheel"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio"; type = "-"; value = 99; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  ############################################################
  #
  # Networking
  #
  ############################################################
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  ############################################################
  #
  # Time & Locale
  #
  ############################################################
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  ############################################################
  #
  # System-Wide Dark Theme & Styling
  #
  ############################################################
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "adwaita-dark";
  };

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-application-prefer-dark-theme=1
    gtk-icon-theme-name=Papirus-Dark
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-icon-theme-name=Papirus-Dark
  '';

  ############################################################
  #
  # Mouse & Libinput
  #
  ############################################################
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat";
      accelSpeed = "-0.3";
    };
  };

  ############################################################
  #
  # X11 & i3 Window Manager
  #
  ############################################################
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;

    # Forces the system to use the dedicated AMD driver.
    videoDrivers = [ "amdgpu" ];

    # Keyboard repeat rate: 650ms delay, 50 repeats per second.
    autoRepeatDelay = 650;
    autoRepeatInterval = 50;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock
      ];
    };

    # Configure keymap in X11
    xkb = {
      layout = "de";
      variant = "";
      # Completely disables the CapsLock key
      options = "caps:none";
    };

    # TearFree handles VSync perfectly.
    deviceSection = ''
      Option "TearFree" "true"
    '';
  };

  console.keyMap = "de";

  ############################################################
  #
  # Gaming Performance (Gamemode)
  #
  ############################################################
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "on";
        inhibit_screensaver = 1;
      };
      cpu = {
        gov = "performance";
      };
      gpu = {
        amd_performance_level = "high";
      };
    };
  };

  ############################################################
  #
  # CoolerControl (Fan & GPU Control)
  #
  ############################################################
  programs.coolercontrol.enable = true;

  ############################################################
  #
  # Shell Aliases & Auto-run Fastfetch
  #
  ############################################################
  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch";
  };

  programs.bash.interactiveShellInit = "fastfetch";

  ############################################################
  #
  # Display Manager (Login Screen)
  #
  ############################################################
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "none+i3";

  ############################################################
  #
  # Dotfiles Management (System-wide)
  #
  ############################################################

  # --- Picom Compositor Configuration (Fixed Skipping & Tearing) ---
  environment.etc."xdg/picom.conf".text = ''
    backend = "glx";
    vsync = false;
    use-damage = false;
    shadow = false;
    fading = false;
    inactive-dim = 0;
  '';

  # --- Fastfetch Configuration (1990s Retro Green Style) ---
  environment.etc."xdg/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "nixos",
        "padding": {
          "top": 1,
          "left": 1,
          "right": 3
        }
      },
      "display": {
        "separator": " -> ",
        "color": {
          "keys": "2"
        }
      },
      "modules": [
        "title",
        "separator",
        "os",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "display",
        "de",
        "wm",
        "theme",
        "icons",
        "terminal",
        "cpu",
        "gpu",
        "memory",
        "swap",
        "disk",
        "localip",
        "locale"
      ]
    }
  '';

  # --- i3 Status Bar Configuration ---
  environment.etc."xdg/i3status.conf".text = ''
    general {
      colors = true
      interval = 5
      color_good = "#FFFFFF"
      color_degraded = "#888888"
      color_bad = "#FF0000"
      separator = " | "
    }

    order += "disk /"
    order += "cpu_usage"
    order += "memory"
    order += "volume master"
    order += "tztime local"

    disk / {
      format = "DISK %used / %total"
    }

    cpu_usage {
      format = "CPU %usage"
    }

    memory {
      format = "RAM %used / %total"
      threshold_degraded = "10%"
      format_degraded = "RAM LOW %available"
    }

    volume master {
      format = "VOL %volume"
      format_muted = "VOL MUTE"
      device = "pulse"
    }

    tztime local {
      format = "%Y-%m-%d %H:%M"
    }
  '';

  # --- Tmux Configuration (Omarchy Style) ---
  environment.etc."tmux.conf".text = ''
    # ============================================================
    # General Settings
    # ============================================================
    set -g prefix C-Space
    unbind C-b
    bind C-Space send-prefix

    set -g mouse on

    set -g base-index 1
    setw -g pane-base-index 1
    set -g renumber-windows on

    set -g default-terminal "tmux-256color"
    set -ga terminal-overrides ",xterm-256color:Tc"

    # ============================================================
    # Keybindings (Omarchy Manual)
    # ============================================================
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

    bind -n M-Left previous-window
    bind -n M-Right next-window

    bind -n M-Up switch-client -p
    bind -n M-Down switch-client -n

    bind c new-window -c "#{pane_current_path}"
    bind k confirm-before -p "kill-window #W? (y/n)" kill-window
    bind r command-prompt -I "#W" "rename-window -- '%%'"

    bind C command-prompt -I "#S" "new-session -s '%%'"
    bind K confirm-before -p "kill-session #S? (y/n)" kill-session
    bind R command-prompt -I "#S" "rename-session -- '%%'"
    bind s choose-session

    # ============================================================
    # Status Bar (Bottom, Minimal Black)
    # ============================================================
    set -g status-position bottom
    set -g status-bg default
    set -g status-fg white
    set -g status-justify centre

    set -g status-left "#[fg=white,bold] #S "
    set -g status-right "#[fg=white,bold] %Y-%m-%d  %H:%M "

    set -g window-status-current-format "#[fg=black,bg=white,bold] #I:#W "
    set -g window-status-format "#[fg=white,dim] #I:#W "
  '';

  # --- i3 Window Manager Configuration ---
  environment.etc."xdg/i3/config".text = ''
    # ============================================================
    # Variables
    # ============================================================
    set $mod Mod4
    set $term ${kittyBin} --single-instance -e ${tmuxBin} new -A -s main
    set $menu ${rofiMenuBin}
    set $browser ${firefoxBin}
    set $files ${thunarBin}

    # ============================================================
    # Fonts
    # ============================================================
    font pango:Monocraft 10

    # ============================================================
    # Window Rules & Appearance (Omarchy Minimal)
    # ============================================================
    floating_modifier $mod
    default_border pixel 2
    default_floating_border pixel 2
    smart_borders on
    gaps inner 0
    gaps outer 0

    for_window [class="Pavucontrol"] floating enable
    for_window [class="Flameshot"] floating enable
    for_window [class="Nm-applet"] floating enable

    # ============================================================
    # Omarchy Core Binds
    # ============================================================
    bindsym $mod+Return exec $term
    bindsym $mod+d exec --no-startup-id $menu
    bindsym $mod+Shift+Return exec $browser
    bindsym $mod+Shift+f exec $files
    bindsym $mod+Ctrl+t exec --no-startup-id ${kittyBin} -e ${btopBin}
    bindsym $mod+Ctrl+a exec --no-startup-id ${pavucontrolBin}
    bindsym $mod+Ctrl+w exec --no-startup-id ${kittyBin} -e ${nmtuiBin}

    # Window Management
    bindsym $mod+w kill
    bindsym $mod+q exec --no-startup-id ${xdotoolBin} getwindowfocus windowkill

    bindsym Ctrl+Mod1+Delete exec i3-msg [class=".*"] kill
    bindsym $mod+t floating toggle
    bindsym $mod+f fullscreen toggle
    bindsym $mod+Mod1+f resize set 100 ppt 100 ppt
    
    # Omarchy Layout Binds
    bindsym $mod+j split toggle
    bindsym $mod+l layout toggle split tabbed stacking
    bindsym $mod+p layout toggle split
    bindsym $mod+g layout tabbed
    
    bindsym $mod+o sticky toggle; floating toggle

    bindsym $mod+Escape exec "i3-nagbar -t warning -m 'System Menu' -B 'Lock' '${i3lockBin} -c 000000' -B 'Suspend' 'systemctl suspend' -B 'Reboot' 'systemctl reboot' -B 'Poweroff' 'systemctl poweroff'"
    bindsym $mod+Ctrl+l exec --no-startup-id ${i3lockBin} -c 000000

    # ============================================================
    # Gaming Shortcuts
    # ============================================================
    bindsym $mod+Shift+g exec --no-startup-id ${gamescopeBin} -W 1920 -H 1080 -r 180 -- ${steamBin} -tenfoot

    # ============================================================
    # Workspace Bindings
    # ============================================================
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

    workspace $ws6 output HDMI-A-0
    workspace $ws7 output HDMI-A-0
    workspace $ws8 output HDMI-A-0
    workspace $ws9 output HDMI-A-0
    workspace $ws10 output HDMI-A-0

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

    bindsym $mod+Tab workspace next
    bindsym $mod+Shift+Tab workspace prev
    bindsym $mod+Ctrl+Tab workspace back_and_forth

    # ============================================================
    # Window Movement & Focus
    # ============================================================
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    bindsym Mod1+Tab focus right
    bindsym Mod1+Shift+Tab focus left

    # ============================================================
    # Resizing (Omarchy Style)
    # ============================================================
    bindsym $mod+equal resize shrink width 10 px or 10 ppt
    bindsym $mod+minus resize grow width 10 px or 10 ppt
    bindsym $mod+Shift+equal resize grow height 10 px or 10 ppt
    bindsym $mod+Shift+minus resize shrink height 10 px or 10 ppt

    # ============================================================
    # Scratchpad & Workflow
    # ============================================================
    bindsym $mod+s scratchpad show
    bindsym $mod+Mod1+s move scratchpad

    bindsym $mod+grave exec --no-startup-id ${kittyBin} --single-instance --name=dropdown -e ${tmuxBin} new -A -s main
    for_window [class="dropdown"] floating enable, resize set 80 ppt 60 ppt, move position center

    # ============================================================
    # Notifications
    # ============================================================
    bindsym $mod+comma exec --no-startup-id ${dunstctlBin} close
    bindsym $mod+Shift+comma exec --no-startup-id ${dunstctlBin} close-all
    bindsym $mod+Ctrl+comma exec --no-startup-id ${dunstctlBin} toggle-pause

    # ============================================================
    # Media & Capture Keys
    # ============================================================
    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle

    bindsym XF86AudioPlay exec --no-startup-id ${playerctlBin} play-pause
    bindsym XF86AudioNext exec --no-startup-id ${playerctlBin} next
    bindsym XF86AudioPrev exec --no-startup-id ${playerctlBin} previous
    bindsym XF86AudioStop exec --no-startup-id ${playerctlBin} stop

    bindsym XF86MonBrightnessUp exec --no-startup-id ${brightnessctlBin} set +10%
    bindsym XF86MonBrightnessDown exec --no-startup-id ${brightnessctlBin} set 10%-

    bindsym Print exec ${flameshotBin} full -c
    bindsym $mod+Ctrl+c exec ${flameshotBin} gui

    # ============================================================
    # Autostart
    # ============================================================
    # Combined xrandr command for perfect 180Hz/75Hz sync on correct monitors
    exec --no-startup-id ${xrandrBin} --output DisplayPort-0 --mode 1920x1080 --rate 180.00 --primary --output HDMI-A-0 --mode 1920x1080 --rate 74.97 --right-of DisplayPort-0
    
    exec --no-startup-id ${dexBin} --autostart --environment i3
    exec --no-startup-id ${xssLockBin} --transfer-sleep-lock -- ${i3lockBin} --nofork
    exec --no-startup-id ${nmAppletBin}
    exec --no-startup-id ${dunstBin}
    exec --no-startup-id ${xsetrootBin} -solid black
    exec --no-startup-id ${picomBin} --config /etc/xdg/picom.conf
    exec --no-startup-id /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1

    # ============================================================
    # Reload & Exit
    # ============================================================
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+r restart

    # ============================================================
    # Status Bar
    # ============================================================
    bar {
            status_command ${i3statusBin} -c /etc/xdg/i3status.conf
            position bottom
            font pango:Monocraft 10
            tray_output primary
            workspace_buttons yes

            colors {
                    background #000000
                    statusline #FFFFFF
                    separator  #666666

                    #                  border  backgr. text
                    focused_workspace  #333333 #333333 #FFFFFF
                    active_workspace   #1A1A1A #1A1A1A #FFFFFF
                    inactive_workspace #000000 #000000 #888888
                    urgent_workspace   #FF0000 #FF0000 #FFFFFF
                    binding_mode       #FF0000 #FF0000 #FFFFFF
            }
    }

    # ============================================================
    # Colors
    # ============================================================
    set $bg     #000000
    set $fg     #FFFFFF
    set $border #333333
    set $inactive #1A1A1A
    set $urgent #FF0000

    client.focused          $border   $border   $fg       $border   $border
    client.focused_inactive $inactive $inactive $fg       $inactive $inactive
    client.unfocused        $bg       $bg       #888888   $bg       $bg
    client.urgent           $urgent   $urgent   $fg       $urgent   $urgent
    client.placeholder      $bg       $bg       $fg       $bg       $bg
  '';

  ############################################################
  #
  # Audio (PipeWire)
  #
  ############################################################
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.pulseaudio.enable = false;

  ############################################################
  #
  # Bluetooth
  #
  ############################################################
  hardware.bluetooth.enable = false;

  ############################################################
  #
  # Graphics & Gaming
  #
  ############################################################
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  hardware.graphics.extraPackages = with pkgs; [
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  programs.steam.enable = true;

  ############################################################
  #
  # Fonts
  #
  ############################################################
  fonts.packages = with pkgs; [
    monocraft
  ];

  ############################################################
  #
  # User Configuration
  #
  ############################################################
  users.users."torbenn" = {
    isNormalUser = true;
    description = "torbenn";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  ############################################################
  #
  # System Packages
  #
  ############################################################
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # --- Development ---
    bat
    bun
    cargo
    clang
    cmake
    curl
    dotnet-sdk
    eza
    fd
    firefox
    gcc
    git
    jq
    kitty
    neovim
    ninja
    nodejs
    python3
    python3Packages.pip
    ripgrep
    rustc
    thunar
    tmux
    unzip
    vscode
    wget
    yq
    zip

    # --- CLI Utilities ---
    btop
    fastfetch
    htop
    libva-utils
    lsof
    mesa-demos
    ncdu
    pciutils
    radeontop
    strace
    tree
    usbutils
    vulkan-tools
    killall

    # --- Gaming ---
    corectrl
    dxvk
    gamescope
    lutris
    mangohud
    protonup-qt
    vinegar
    wineWowPackages.stable # Ignore the warning, let it finish!
    winetricks
    noriskclient-launcher

    # --- Desktop & GUI ---
    adwaita-qt
    brightnessctl
    dex
    discord
    dunst
    feh
    flameshot
    gnome-themes-extra
    i3
    i3lock
    kitty
    networkmanagerapplet
    papirus-icon-theme
    pavucontrol
    picom
    playerctl
    polkit_gnome
    rofi
    spotify # Added standard Spotify
    vesktop
    xclip
    xdotool
    xsel
    xss-lock

    # --- Custom Scripts ---
    rofiMenuScript
  ];

  ############################################################
  #
  # Services & Portals
  #
  ############################################################
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  ############################################################
  #
  # Nix Auto Garbage Collection
  #
  ############################################################
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.auto-optimise-store = true;

  ############################################################
  #
  # System State
  #
  ############################################################
  system.stateVersion = "26.05";

  ## v3.6
}
