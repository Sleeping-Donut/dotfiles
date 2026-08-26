{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  buildPackages,
  kdePackages,
  nix-update-script,
  ...
}:

buildNpmPackage {
  pname = "trek";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "liketrek";
    repo = "TREK";
    rev = "v3.4.1";
    hash = "sha256-r7Y6vxksX+V4bKCz4MF7K8Ar5UgKIzHoJmjukgR+9Cw="; # nix-prefetch-github liketrek TREK --rev v3.4.1
  };

  npmDepsHash = "sha256-m+2OFN8EbyCv+sc5T3TcNxjR5tl9qKMzqyLIqrTrews="; # prefetch-npm-deps package-lock.json

  nodejs = nodejs_24;

  nativeBuildInputs = [
    python3
    buildPackages.gcc
    buildPackages.gnumake
  ];

  propagatedBuildInputs = [
    kdePackages.libkitinerary
  ];

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/trek
    cp -r . $out/lib/node_modules/trek

    mkdir -p $out/bin
    cat > $out/bin/trek <<EOF
    #!/bin/sh
    cd $out/lib/node_modules/trek/server
    exec node --require tsconfig-paths/register dist/index.js
    EOF
    chmod +x $out/bin/trek

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Travel itinerary and boarding pass manager";
    homepage = "https://github.com/liketrek/TREK";
    license = lib.licenses.gpl3Plus;
    mainProgram = "trek";
    platforms = lib.platforms.linux;
  };
}
