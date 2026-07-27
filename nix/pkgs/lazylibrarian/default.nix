{ lib, stdenv, fetchFromGitLab, fetchurl, python3, makeWrapper }:

let
  py = python3;
  versions = builtins.fromJSON (builtins.readFile ./versions.json);

  slskd-api = py.pkgs.buildPythonPackage rec {
    pname = "slskd-api";
    version = versions.slskd-api.version;
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/source/s/slskd-api/slskd_api-${version}.tar.gz";
      hash = versions.slskd-api.hash;
    };
    propagatedBuildInputs = [ py.pkgs.requests ];
    doCheck = false;
    pythonImportsCheck = [ "slskd_api" ];
  };

  iso639-lang = py.pkgs.buildPythonPackage rec {
    pname = "iso639-lang";
    version = versions.iso639-lang.version;
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/source/i/iso639-lang/iso639_lang-${version}.tar.gz";
      hash = versions.iso639-lang.hash;
    };
    doCheck = false;
    pythonImportsCheck = [ "iso639" ];
  };

  pythonEnv = py.withPackages (ps: with ps; [
    beautifulsoup4
    html5lib
    webencodings
    requests
    urllib3
    pyopenssl
    cherrypy
    cherrypy-cors
    httpagentparser
    mako
    httplib2
    pillow
    apprise
    pypdf
    python-magic
    rapidfuzz
    deluge-client
    pyparsing
    irc
    apscheduler
    tzdata
    lxml
    xmltodict
    googletrans
    slskd-api
    iso639-lang
  ]);
in
stdenv.mkDerivation {
  pname = "lazylibrarian";
  version = "2026.05.25";

  src = fetchFromGitLab {
    owner = "LazyLibrarian";
    repo = "LazyLibrarian";
    rev = versions.rev;
    hash = versions.hash;
  };

  dontBuild = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/lazylibrarian $out/bin
    cp -r * $out/share/lazylibrarian/
    sed -i 's/LAZYLIBRARIAN_VERSION = "master"/LAZYLIBRARIAN_VERSION = "package"/' \
      $out/share/lazylibrarian/lazylibrarian/version.py
    echo 'LAZYLIBRARIAN_HASH = "${versions.rev}"' >> $out/share/lazylibrarian/lazylibrarian/version.py
    makeWrapper ${pythonEnv}/bin/python $out/bin/lazylibrarian \
      --add-flags "$out/share/lazylibrarian/LazyLibrarian.py"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A SickBeard, CouchPotato, Headphones-like application for ebooks, audiobooks and magazines";
    homepage = "https://gitlab.com/LazyLibrarian/LazyLibrarian";
    license = licenses.gpl3Only;
    mainProgram = "lazylibrarian";
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
