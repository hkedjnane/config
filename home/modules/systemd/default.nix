{ lib, pkgs, config, ... }: 
let
  battery_notifier_script = pkgs.writeShellScript "battery_notifier.sh" ''
    BATTERY_THRESHOLD=10
    POLLING_RATE_SECS=30
    IS_BELOW_THRESHOLD=false

    while true; do
      BATTERY_LEVEL=`${pkgs.acpi}/bin/acpi -b | ${pkgs.grep}/bin/grep -P -o '[0-9]+(?=%)'`
      if [ "$BATTERY_LEVEL" -le "$BATTERY_THRESHOLD" ]; then
        if [ $IS_BELOW_THRESHOLD = false ]; then
          notify-send "Battery low" "$BATTERY_LEVEL"
          IS_BELOW_THRESHOLD=true
        fi
      else
        IS_BELOW_THRESHOLD=false
      fi
      sleep $POLLING_RATE_SECS
    done
  '';
in
{
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
