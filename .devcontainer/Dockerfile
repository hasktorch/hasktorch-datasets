ARG BASE_IMAGE

# ------------------------
# Target: dev
# ------------------------
FROM $BASE_IMAGE as dev

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

RUN nix-env -i git zsh