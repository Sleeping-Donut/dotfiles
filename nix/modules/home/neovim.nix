{ lib, pkgs, pkgs-unstable, config, ... }:
let
	cfg = config.nd0.home.neovim;
in
{
	options.nd0.home.neovim = {
		enable = lib.mkEnableOption "Whether to install neovim in home";
		cop = lib.mkOption {
			type = lib.types.bool;
			default = true;
			description = "Whether to do bare install";
		};
		lsps = lib.mkEnableOption "Whether to install LSPs";
		formatters = lib.mkEnableOption "Whether to install formatters";
		ts-parsers = lib.mkEnableOption "Whether to install treesitter parsers";
	};

	config = lib.mkIf cfg.enable {
		programs.neovim = {
			enable = true;
			extraPackages = with pkgs-unstable; let
				lsp-pkgs = if !cfg.lsps then [] else [
					ccls
					# csharp-ls # unsupported for darwin
					emmet-ls
					# fsautocomplete # unsupported for darwin
					gopls
					java-language-server
					kotlin-language-server
					lua-language-server
					luajitPackages.lua-lsp
					nil
					ocamlPackages.lsp
					python311Packages.python-lsp-server
					rust-analyzer
					nil
					nixd
					tailwindcss-language-server
					yaml-language-server
				];
				fmt-pkgs = if !cfg.formatters then [] else [
					alejandra
					rustfmt
					stylua
				];
				ts-pkgs = if !cfg.ts-parsers then [] else with tree-sitter-grammars; [
					tree-sitter-c
					tree-sitter-go
					tree-sitter-vim
					tree-sitter-css
					tree-sitter-lua
					tree-sitter-zig
					tree-sitter-cpp
					tree-sitter-nix
					tree-sitter-pug
					tree-sitter-php
					tree-sitter-tsx
					tree-sitter-sql
					tree-sitter-vue
					tree-sitter-wgsl
					tree-sitter-perl
					tree-sitter-rust
					tree-sitter-toml
					tree-sitter-cuda
					tree-sitter-yaml
					tree-sitter-scss
					tree-sitter-http
					tree-sitter-llvm
					tree-sitter-make
					tree-sitter-ruby
					tree-sitter-html
					tree-sitter-json
					tree-sitter-bash
					tree-sitter-fish
					tree-sitter-glsl
					tree-sitter-java
					tree-sitter-dart
					tree-sitter-scala
					tree-sitter-proto
					tree-sitter-latex
					tree-sitter-regex
					tree-sitter-ocaml
					tree-sitter-elisp
					tree-sitter-jsdoc
					tree-sitter-gomod
					tree-sitter-erlang
					tree-sitter-prisma
					tree-sitter-elixir
					tree-sitter-kotlin
					tree-sitter-gomod
					tree-sitter-python
					tree-sitter-svelte
					tree-sitter-bibtex
					tree-sitter-graphql
					tree-sitter-haskell
					tree-sitter-c-sharp
					tree-sitter-comment
					tree-sitter-markdown
					tree-sitter-gdscript
					tree-sitter-commonlisp
					tree-sitter-dockerfile
					tree-sitter-typescript
					tree-sitter-javascript
					tree-sitter-godot-resource
					tree-sitter-ocaml-interface
				];
			in
				lsp-pkgs ++ fmt-pkgs ++ ts-pkgs;
		};
		home.file.".config/nvim/init.lua".source = ../../../config/nvim/init.lua;
		home.file.".config/nvim/lua".source = ../../../config/nvim/lua;
		home.file.".config/nvim/lazy-lock.json".source =
			config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/nvim/lazy-lock.json";
	};
}
