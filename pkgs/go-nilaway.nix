{ buildGoModule, fetchFromGitHub, ... }:

buildGoModule  {
  pname = "nilaway";
  version = "unstable-2023-11-17";

  src = fetchFromGitHub {
	owner = "uber-go";
	repo = "nilaway";
	rev = "755a685ab68b85d9b36833b38972a559f217d396";
	hash = "sha256-sDDBITrGD79pcbsrcrs6D8njBp4kuK1NkuBPwzIkaUE=";
  };

  vendorHash = "sha256-kbVjkWW5D8jp5QFYGiyRuGFArRsQukJIR8xwaUUIUBs=";

  ldflags = [ "-s" "-w" ];
}

