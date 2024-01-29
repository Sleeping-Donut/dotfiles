{
	nixpkgs, nixpkgs-unstable, nur, hostname,
	nix-modules, darwin-modules, darwin-home-modules,
	homebrew-modules, home-manager-modules,
	...
}:
let
in
{
	imports = [
		nix-home-modules.neovim { inherit (nixpkgs) lib; pkgs = nixpkgs; }
	];
	system = "aarch64-darwin";

	home-manager-modules {
		modules = [];

		home.stateVersion = "23.11";
		home.file."".text = "23.11";

		nd0.home = {
			neovim.enable = true;
			firefox.enable = true;
	};
}
