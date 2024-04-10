# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, lib, buildGoModule, fetchFromGitHub, ...}: {
  # dont know how to make shellcheck happy
  pandoc-for-homework = pkgs.writeShellScriptBin "pandoc-for-homework" ''
    readarray -d "" entries < <(printf '%s\0' *.md | sort -zV)
    for f in "''${entries[@]}"; do
      pandoc -F mermaid-filter -V geometry:margin=0.5in -s -o "''${f%.*}".pdf "''${f}"
    done
    pdftk $(ls -1v ./task*.pdf) cat output "$1"
  '';

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

  go-nilaway =
	buildGoModule rec {
	  pname = "nilaway";
	  version = "unstable-2023-11-17";

	  src = fetchFromGitHub {
		owner = "uber-go";
		repo = "nilaway";
		rev = "755a685ab68b85d9b36833b38972a559f217d396";
		hash = "";
	  };

	  vendorHash = "sha256-kbVjkWW5D8jp5QFYGiyRuGFArRsQukJIR8xwaUUIUBs=";

	  ldflags = [ "-s" "-w" ];
	};
}
