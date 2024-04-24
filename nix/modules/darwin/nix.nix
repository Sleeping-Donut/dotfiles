{ ... }:
{
	nix = {
		settings.experimental-features = [ "nix-command" "flakes" ];	
		# garbage Collection
		gc = {
			automatic = true;
			interval = { Hour = 3; };
			options = "--delete-older-than 20d";
		};
		extraOptions = ''
		auto-optimise-store = true
		experimental-features = nix-command flakes
		'';
	};
}

