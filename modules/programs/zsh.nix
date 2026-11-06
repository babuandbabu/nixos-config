# Zsh made compatible with YOUR existing ~/.zshrc (not replaced).
# Your .zshrc expects:   ZSH=$HOME/.oh-my-zsh, theme powerlevel10k/powerlevel10k,
# plugins git zsh-autosuggestions zsh-syntax-highlighting in the OMZ "custom" dir.
# On NixOS we BUILD such a tree from nixpkgs packages, expose it at /etc/oh-my-zsh,
# and deploy-dotfiles.sh links ~/.oh-my-zsh -> /etc/oh-my-zsh.
{ pkgs, ... }:
let
  ohMyZshTree = pkgs.runCommand "oh-my-zsh-tree" { } ''
    cp -r ${pkgs.oh-my-zsh}/share/oh-my-zsh $out
    chmod -R u+w $out
    mkdir -p $out/custom/plugins/zsh-autosuggestions \
             $out/custom/plugins/zsh-syntax-highlighting \
             $out/custom/themes
    echo 'source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh' \
      > $out/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
    echo 'source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' \
      > $out/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
    ln -s ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k $out/custom/themes/powerlevel10k
  '';
in
{
  programs.zsh = {
    enable = true;
    # Oh My Zsh runs its own compinit and p10k draws the prompt, so switch off
    # NixOS's global ones to avoid double init / prompt clashes.
    enableGlobalCompInit = false;
    promptInit = "";
    # /etc/zshenv: the Nix store is read-only, so give Oh My Zsh a writable cache.
    shellInit = ''
      export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
      mkdir -p "$ZSH_CACHE_DIR/completions"
    '';
  };

  environment.etc."oh-my-zsh".source = ohMyZshTree;
  # zoxide is installed in packages.nix; your .zshrc already runs `zoxide init`.
}
