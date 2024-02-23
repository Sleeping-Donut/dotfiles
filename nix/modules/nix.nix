{ ... }:
{
	nix = {
		# garbage Collection
		gc = {
			automatic = true;
			interval.Day = 14;
			options = "--delete-older-than 14d";
		};
		extraOptions = ''
		auto-optimise-store = true
		experimental-features = nix-command flakes
		'';
	};
}

