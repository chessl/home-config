{ stdenv, requireFile, unzip, nerd-font-patcher, lib }:

stdenv.mkDerivation rec {
  name = "monolisa-nerd";
  version = "2.015";

  src = requireFile rec {
    name = "MonoLisa-Complete-${version}.zip";
    sha256 = "1axdqsvd8radcnlw5klsabz5sqg1vij1wjrdf3nfkdfb59s7bx7y";
    message = ''
      ${name} font not found in nix store, to add it run:
      $ nix-store --add-fixed sha256 /path/to/${name}

      Did you change the file? maybe you need to update the sha256
      $ nix-hash --flat --base32 --type sha256 /path/${name}'';
  };

  buildInputs = [ unzip nerd-font-patcher ];
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  pathsToLink = [ "/share/fonts/truetype/" ];
  sourceRoot = ".";

  buildPhase = ''
    find -name "MonoLisa*.ttf" -exec nerd-font-patcher {} --complete --no-progressbars ./ \;
  '';

  installPhase = ''
    install_path=$out/share/fonts/truetype
    mkdir -p $install_path
    find -name "MonoLisa*.ttf" -exec cp {} $install_path \;
  '';

  meta = with lib; {
    homepage = "https://monolisa.dev";
    description = ''
      As software developers, we always strive for better tools but rarely consider font as such. Yet we spend most of our days looking at screens reading and writing code. Using a wrong font can negatively impact our productivity and lead to bugs. MonoLisa was designed by professionals to improve developers’ productivity and reduce fatigue.
    '';
    platforms = platforms.all;
    licence = licences.unfree;
  };
}

