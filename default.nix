{ stdenv
, pkgs ? (import <nixpkgs> {})
}:

let
  env = with pkgs; [
    bundler
    ruby_2_2_2
  ];
in

stdenv.mkDerivation rec {
    name = "ical-view";
    src = ./.;
    version = "0.0.0";

    buildInputs = [ env ];

}

