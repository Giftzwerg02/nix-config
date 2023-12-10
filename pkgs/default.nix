# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...} : {
  pandoc-for-homework = pkgs.writeShellApplication {
    name = "pandoc-for-homework";
    runtimeInputs = with pkgs; [ pandoc pdftk ];
    text = ''
    readarray -d "" entries < <(printf '%s\0' *.md | sort -zV)
    for f in "''${entries[@]}"; do 
      pandoc -F mermaid-filter -V geometry:margin=0.5in -s -o "''${f%.*}".pdf "''${f}"
    done
    pdftk $(ls -1v ./task*.pdf) cat output "$1"
    '';
  };
}
