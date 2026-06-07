FROM nixos/nix:latest

RUN echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf
RUN nix profile add \
  nixpkgs#jq \
  github:nixos/nixpkgs/nixos-unstable#opencode
ENV PATH="${PATH}:/root/.nix-profile/bin:/.nix-profile/bin"

COPY --chmod=+x entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
