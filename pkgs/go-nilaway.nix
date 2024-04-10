{ lib, buildGoModule, fetchFromGitHub, ... }:

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
}

