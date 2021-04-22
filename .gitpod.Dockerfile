FROM gitpod/workspace-full

USER gitpod

# Install LaTeX
RUN sudo apt-get -q update \
 && sudo apt-get install -yq texlive-latex-extra \
 && sudo rm -rf /var/lib/apt/lists/* \
 && curl -fsSL https://starship.rs/install.sh | bash -s -- --yes
