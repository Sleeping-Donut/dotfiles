{ ... }:
{
	nix.settings.experimental-features = [
		"nix-command" "flakes" "pipe-operators" #"lazy-trees"
	];
}

