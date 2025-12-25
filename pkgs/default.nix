{pkgs, ...}: {
  toggle-redshift =
    pkgs.writeShellApplication
    {
      name = "toggle-redshift";
      runtimeInputs = [];
      text = ''
        if systemctl --user --quiet is-active redshift.service
        then
          systemctl --user stop redshift.service
        else
          systemctl --user start redshift.service
        fi
      '';
    };
}
