{ 
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: 

let
domain = "giftzwerg02.duckdns.org";
hostAddress = "10.0.0.239";
localAddress = {
	nextcloud = "192.168.100.11";
	gitea = "192.168.100.12";
	personalWebpage = "192.168.100.13";
	minecraft = "192.168.100.14";
};
ports = {
	ssh = 22;
	giteaSSH = 2222;
	giteaHTTP = 3000;
	nextcloud = 4000;
	personalWebpage = { http = 80; https = 443; hugo = 1313; };
	minecraft = { s1 = 25565; rcon = 25575; };
};
in
{
	imports = [
		./hardware-configuration.nix
		inputs.nix-minecraft.nixosModules.minecraft-servers
		inputs.sops-nix.nixosModules.sops
	];

	nix = {
		# This will add each flake input as a registry
		# To make nix3 commands consistent with your flake
		registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

		# This will additionally add your inputs to the system's legacy channels
		# Making legacy nix commands consistent as well, awesome!
		nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

		settings = {
		  # Enable flakes and new 'nix' command
		  experimental-features = "nix-command flakes";
		  # Deduplicate and optimize nix store
		  auto-optimise-store = true;

		  # Force clean git-directory before rebuilding
		  allow-dirty = false;
		};
	};

	sops = {
		defaultSopsFile = ./secrets/secrets.yaml;
		defaultSopsFormat = "yaml";
		age.keyFile = "/root/.config/sops/age/keys.txt";

		secrets = {
			"minecraft-servers/vanilla-1/rcon-password" = {
			};
		};
	};

	nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

	boot.tmp.cleanOnBoot = true;
	zramSwap.enable = true;
	networking.hostName = "giftzwerg02-nixos";
	networking.domain = "";
	services.openssh.enable = true;
	users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHkgGByPMod2GuNEvMY6ZQPTxLGFWqdUyR6/378hqC5 benjamin.komar@kabsi.at'' ];

	containers.minecraft-servers= {
		inherit hostAddress;
		autoStart = true;
		forwardPorts = [ 
			{ containerPort = ports.minecraft.s1; hostPort = ports.minecraft.s1; } 
			{ containerPort = ports.minecraft.rcon; hostPort = ports.minecraft.rcon; } 
		];
		bindMounts = { 
			"${config.sops.secrets."minecraft-servers/vanilla-1/rcon-password".path}".isReadOnly = true; 
		};
		privateNetwork = true;
		localAddress = localAddress.minecraft; 
		config = { config, pkgs, ... }: {
			imports = [ 
				inputs.nix-minecraft.nixosModules.minecraft-servers
				inputs.sops-nix.nixosModules.sops
			];
			nixpkgs.config.allowUnfree = true;

			sops = {
				defaultSopsFile = ./secrets/secrets.yaml;
				defaultSopsFormat = "yaml";
				age.keyFile = "/root/.config/sops/age/keys.txt";

				secrets = {
					"minecraft-servers/vanilla-1/rcon-password" = {
						owner = "minecraft";
					};
				};
			};

			services.minecraft-servers = {
				enable = true;
				eula = true;	
				environmentFile = pkgs.writeText "test-file.txt" ''
					rconpwd=$(cat ${config.sops.secrets."minecraft-servers/vanilla-1/rcon-password".path})
				'';
				serviceConfig.ExecStart = ''foobar'';
				servers = {
					vanilla-1 = {
						enable = true;
						serverProperties = {
							server-port = ports.minecraft.s1;
							gamemode = "survival";
							difficulty = "easy";
							simulation-distance = 16;

							enable-rcon = true;
							"rcon.password" = "@rconpwd@";
							"rcon.port" = ports.minecraft.rcon;
							broadcast-rcon-to-ops = false;
						};
					};
				};
			}.overrideAttr;

			


			system.stateVersion = "23.05";

			networking = { 
				firewall = { enable = true; allowedTCPPorts = [ 
					ports.minecraft.s1 
					ports.minecraft.rcon
				]; };
				useHostResolvConf = false;
			};
			services.resolved.enable = true;

		};
	};

	environment.systemPackages = with pkgs; [
		wget
		git
		vim
	];

	networking.nat = {
		enable = true;
		internalInterfaces = [ "ve-+" ];
		externalInterface = "enp0s6";
		enableIPv6 = true;
		forwardPorts = [ {
			sourcePort = ports.giteaSSH;
			proto = "tcp";
			destination = "${localAddress.gitea}:22"			;
		} ];
	};

	containers.personalWebpage = {
		inherit hostAddress;
		autoStart = true;
		privateNetwork = true;
		ephemeral = true;
		localAddress = localAddress.personalWebpage;
		bindMounts = {
			"/var/lib/personalWebpage" = { hostPath = "/var/lib/personalWebpage"; isReadOnly = true; };
		};

		config = { config, pkgs, ...}: {
			environment.systemPackages = with pkgs; [
				git
				static-web-server
				pandoc
				bash
				coreutils
				(python3.withPackages (python-pkgs: [
					python-pkgs.beautifulsoup4
					python-pkgs.requests
				]))
			];


			systemd.services.create-web-dir = {
				serviceConfig.Type = "oneshot";
				path = with pkgs; [ git ];
				after = [ "network.target" ];
				wantedBy = [ "multi-user.target" ];
				script = 
					''
					mkdir -p /var/www
					cd /var/www
					mkdir ctfs
					cd ctfs
					git init
					git remote add origin https://github.com/Giftzwerg02/ctfs
					'';
			};

			systemd.services.update-repositories = {
				serviceConfig.Type = "oneshot";
				path = with pkgs; 
					[ git pandoc bash coreutils 
					  (python3.withPackages (python-pkgs: [
							python-pkgs.beautifulsoup4
							python-pkgs.requests
					  ])) 
					];
				
				script = 
					''
					cp /var/lib/personalWebpage/template.html /var/www
					cp /var/lib/personalWebpage/template.css /var/www
					cp /var/lib/personalWebpage/nav-gen.py /var/www
					cp /var/lib/personalWebpage/favicon-gen.py /var/www
					cd /var/www/ctfs
					git pull origin master

					read -a svgsarr <<< "$(python3 /var/www/favicon-gen.py)"
					svgsarrsize=''${#svgsarr[@]}

					find ./ -iname "*.md" -type f -exec bash -c 'pandoc "''${0}" --template "/var/www/template.html" --metadata title="$(basename ''${0})" --metadata date="$(date -r ''${0} -u +"%Y-%m-%d, %H:%M:%S")" --metadata favicon="''${@:$(($RANDOM % $1)):1}" --variable nav-bar="$(python3 /var/www/nav-gen.py "/var/www" "''${0}")" -c $(realpath --relative-to="''${0}" /var/www/template.css) --no-highlight --toc -o "''${0%.md}.html"' {} "''${svgsarrsize}" "''${svgsarr[@]}" \;
					'';
			};

			systemd.timers.update-repositories = {
				wantedBy = [ "timers.target" ];
				partOf = [ "update-repositories.service" ];
				timerConfig = {
					# https://silentlad.com/systemd-timers-oncalendar-(cron)-format-explained
					OnCalendar = "*:0/5";
					Unit = "update-repositories.service";
				};
			};

			

			services.static-web-server = {
				enable = true;
				listen = "[::]:80";
				root = "/var/www";
				configuration = {
					general = {
						directory-listing = true;
						directory-listing-format = "html";
					};
				};
			};

			networking = {
				firewall = { 
					enable = true; 
					allowedTCPPorts = [ 22 80 443 ports.personalWebpage.hugo ];
				};

				useHostResolvConf = false;
			};
			services.resolved.enable = true;
			system.stateVersion = "23.05";
		};
	};

	containers.nextcloud = {
		inherit hostAddress;
		autoStart = true;
		privateNetwork = true;
		localAddress = localAddress.nextcloud; 
		bindMounts = {
			"/var/lib/nextcloud" = { hostPath = "/var/lib/nextcloud"; isReadOnly = false; };	
			"/etc/nextcloud-admin-pass" = { hostPath = "/etc/nextcloud-admin-pass"; isReadOnly = true; };
		};
		config = { config, pkgs, ... }: {

# nextcloud config :3
			services.nextcloud = {
				enable = true;
				package = pkgs.nextcloud28;
				https = true;
				hostName = domain; 
				configureRedis = true;
				config.adminpassFile = "/etc/nextcloud-admin-pass";
			};	
			system.stateVersion = "23.05";

			networking = { 
				firewall = { enable = true; allowedTCPPorts = [ 80 443 ]; };
				useHostResolvConf = false;
			};
			services.resolved.enable = true;

		};
	};
	containers.gitea = {
		inherit hostAddress;
		autoStart = true;
		privateNetwork = true;
		localAddress = localAddress.gitea;
		bindMounts = {
			"/data" = { hostPath = "/var/lib/gitea"; isReadOnly = false; }; 
		};

		config = { config, pkgs, ... }: {
			
			nixpkgs.config.permittedInsecurePackages = [ "forgejo-1.20.6-1-unstable-2024-04-18" ];

			services.forgejo = {
				enable = true;
				user = "gitea";
				group = "gitea";
				stateDir = "/var/lib/gitea";
				database.name = "gitea";
				database.user = "gitea";
				settings = {
					server = {
						DOMAIN = domain;
						ROOT_URL = "https://${domain}:${toString ports.giteaHTTP}/";
					};
					service = {
						REGISTER_MANUAL_CONFIRM = true;
					};
				};
			};

			users.users.gitea = {
				home = "/var/lib/gitea";
				useDefaultShell = true;
				group = "gitea";
				isSystemUser = true;
			};

			users.groups.gitea = {};

			system.stateVersion = "23.05";
			services.openssh.enable = true;
			networking = {
				firewall = {
					enable = true;
					allowedTCPPorts = [ 22 ports.giteaHTTP ];
				};
				useHostResolvConf = false;
			};
			services.resolved.enable = true;
		};
	};


	services.caddy.enable = true;
	services.caddy = {
		virtualHosts."${domain}:${toString ports.giteaHTTP}".extraConfig = ''
			reverse_proxy http://${localAddress.gitea}:${toString ports.giteaHTTP}
		'';
		virtualHosts."${domain}:${toString ports.nextcloud}".extraConfig = ''
			reverse_proxy ${localAddress.nextcloud}
		'';
		virtualHosts."${domain}:${toString ports.personalWebpage.https}".extraConfig = ''
			reverse_proxy ${localAddress.personalWebpage}
		'';
	};

	virtualisation.docker.enable = true;

	networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
	networking.firewall.allowedTCPPorts = [
		ports.ssh
		ports.nextcloud
		ports.giteaSSH
		ports.giteaHTTP
		ports.minecraft.s1
		ports.minecraft.rcon
		80 
		443
		9999
	];
	system.stateVersion = "23.05";
}
