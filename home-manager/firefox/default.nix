{ 
  ...
}: {
  programs.firefox = {
    enable = true;
    languagePacks = [ "sk" "en-US" "de" ];
    betterfox = {
      enable = true;
      profiles.default.enableAllSections = true;
    };
  };
}
