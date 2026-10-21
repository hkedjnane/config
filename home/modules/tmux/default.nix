{ pkgs, ... }: {
  # Pulled from charybdis (~/.tmux.conf, agent-deck tmux config v4)
  programs.tmux = {
    enable = true;

    # Terminal with true color support
    terminal = "tmux-256color";

    # Performance
    escapeTime = 0;
    historyLimit = 50000;

    # Mouse support (scroll + drag-to-copy)
    mouse = true;

    extraConfig = ''
      set -ag terminal-overrides ",xterm*:Tc:smcup@:rmcup@"
      set -ag terminal-overrides ",*256col*:Tc"

      # Extended keys: forward Shift+Enter and other modified keys to apps (tmux 3.2+)
      set -s extended-keys on
      # Deliver them as ESC[13;2u (the kitty keyboard-protocol form Claude Code reads)
      # rather than xterm modifyOtherKeys ESC[27;2;13~, which Claude Code ignores.
      set -s extended-keys-format csi-u
      set -as terminal-features 'tmux-256color:extkeys'

      # Auto-enter copy-mode when scrolling up
      # This handles: 1) apps with mouse support, 2) already in copy-mode, 3) normal pane
      bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"

      # Scroll bindings in copy-mode (both vi and emacs modes)
      bind-key -T copy-mode-vi WheelUpPane send-keys -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -X scroll-down
      bind-key -T copy-mode WheelUpPane send-keys -X scroll-up
      bind-key -T copy-mode WheelDownPane send-keys -X scroll-down

      # Clipboard integration (drag-to-copy); wl-copy instead of xclip since we run Wayland
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
      bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
    '';
  };
}
