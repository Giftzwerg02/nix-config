{ pkgs, lib, ... }:
let 
	cfg = config.global;
in
{	
	imports = [];
	options = {
		global = {
			enable = lib.mkEnableOption "enable global config";
		};
	};
	config = {
		global = lib.mkIf cfg.enable {
			
		};
	};
}
