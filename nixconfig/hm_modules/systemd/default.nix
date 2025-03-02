{ lib, pkgs, config, ... }: {
  systemd.user.services.ssh-agent = {
    Unit = { Description = "Start SSH agent."; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      Type = "simple";
      Environment = [ "SSH_AUTH_SOCK=%t/ssh-agent.socket" "DISPLAY=:0" ];
      ExecStart = "/run/current-system/sw/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
    };
  };
}
