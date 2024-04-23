{ ... }:
{
	nix = {
		settings.experimental-features = [ "nix-command" "flakes" ];	
		# garbage Collection
		gc = {
			automatic = true;
			dates = "monthly";
			options = "--delete-older-than 20d";
		};
		extraOptions = ''
		auto-optimise-store = true
		experimental-features = nix-command flakes
		'';
	};
}

