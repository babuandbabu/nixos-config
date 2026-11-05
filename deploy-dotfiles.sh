#!/usr/bin/env bash
# deploy-dotfiles.sh — symlink your EXISTING ~/dotfiles into $HOME. No Stow, no Home Manager.
#
#   ./deploy-dotfiles.sh --list                 show groups
#   ./deploy-dotfiles.sh --dry-run              preview everything (changes nothing)
#   ./deploy-dotfiles.sh                        deploy all default groups
#   ./deploy-dotfiles.sh mango noctalia shell   deploy only these groups
#   ./deploy-dotfiles.sh --undo [groups]        remove ONLY symlinks this script made
#   ./deploy-dotfiles.sh --backup               move conflicting files aside (*.pre-nix.<time>)
#   ./deploy-dotfiles.sh --repo /path/to/repo   repo location (default: $DOTFILES or ~/dotfiles)
#
# Safety: never deletes or overwrites. Conflicts are reported and skipped
# (unless --backup, which renames, never deletes). Refuses to run as root.
set -uo pipefail

REPO="${DOTFILES:-$HOME/dotfiles}"
DRY=0; UNDO=0; BACKUP=0
SELECTED=()

# Group -> entries. "path" = same path in repo and $HOME.
# "ABS=REL" = link $HOME/REL to an absolute path outside the repo.
ALL_GROUPS=(shell ohmyzsh mango niri noctalia kitty yazi btop fastfetch fzf gtk qt nwg-look xsettingsd zed wallpapers fonts)
DEFAULT_GROUPS=(shell ohmyzsh mango niri noctalia kitty yazi btop fastfetch fzf gtk qt nwg-look xsettingsd zed wallpapers)
declare -A G=(
  [shell]=".zshrc .p10k.zsh"
  [ohmyzsh]="/etc/oh-my-zsh=.oh-my-zsh"
  [mango]=".config/mango"
  [niri]=".config/niri"
  [noctalia]=".config/noctalia"
  [kitty]=".config/kitty"
  [yazi]=".config/yazi"
  [btop]=".config/btop"
  [fastfetch]=".config/fastfetch"
  [fzf]=".config/fzf"
  [gtk]=".config/gtk-3.0 .config/gtk-4.0"
  [qt]=".config/qt5ct .config/qt6ct"
  [nwg-look]=".config/nwg-look"
  [xsettingsd]=".config/xsettingsd"
  [zed]=".config/zed"
  [wallpapers]="Pictures/Wallpaper"
  [fonts]=".local/share/fonts/JetBrainsMono_1"   # opt-in: fonts come from Nix already
)

ok=0; made=0; skipped=0; conflicts=0; removed=0
say() { printf '%s\n' "$*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY=1 ;;
    -u|--undo)    UNDO=1 ;;
    -b|--backup)  BACKUP=1 ;;
    -r|--repo)    shift; REPO="${1:?--repo needs a path}" ;;
    -l|--list)    for g in "${ALL_GROUPS[@]}"; do printf '%-12s %s\n' "$g" "${G[$g]}"; done; exit 0 ;;
    -h|--help)    sed -n '2,13p' "$0"; exit 0 ;;
    -*)           say "Unknown option: $1"; exit 2 ;;
    *)            SELECTED+=("$1") ;;
  esac
  shift
done

if [[ $EUID -eq 0 ]]; then say "Run as your normal user, not root (links would be owned by root)."; exit 1; fi
if [[ ! -d "$REPO" ]]; then say "Dotfiles repo not found: $REPO (use --repo)"; exit 1; fi
REPO="$(cd "$REPO" && pwd)"
[[ -d "$REPO/.git" ]] || say "Note: $REPO is not a git repo (continuing)."
[[ ${#SELECTED[@]} -eq 0 ]] && SELECTED=("${DEFAULT_GROUPS[@]}")
for g in "${SELECTED[@]}"; do
  [[ -n "${G[$g]+x}" ]] || { say "Unknown group: $g  (try --list)"; exit 2; }
done
[[ $DRY -eq 1 ]] && say "== DRY RUN: nothing will be changed =="

run() { if [[ $DRY -eq 1 ]]; then say "   would: $*"; else "$@"; fi; }

link_one() {
  local src="$1" rel="$2" dst="$HOME/$2"

  if [[ $UNDO -eq 1 ]]; then
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
      say "[unlink]  $dst"; run rm "$dst"; removed=$((removed+1))
    else
      say "[skip]    $dst (not a link created for this repo)"; skipped=$((skipped+1))
    fi
    return
  fi

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    say "[missing] $src (not in repo / not built yet) — skipped"; skipped=$((skipped+1)); return
  fi

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      say "[ok]      $dst"; ok=$((ok+1)); return
    fi
    say "[CONFLICT] $dst is a symlink to $(readlink "$dst")"
  elif [[ -e "$dst" ]]; then
    say "[CONFLICT] $dst already exists (real file/dir)"
  else
    say "[link]    $dst -> $src"
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"; made=$((made+1)); return
  fi

  if [[ $BACKUP -eq 1 ]]; then
    local bak="$dst.pre-nix.$(date +%Y%m%d%H%M%S)"
    say "          backing up to $bak"
    run mv "$dst" "$bak"
    run ln -s "$src" "$dst"; made=$((made+1))
  else
    conflicts=$((conflicts+1))
  fi
}

for g in "${SELECTED[@]}"; do
  say "--- $g ---"
  for entry in ${G[$g]}; do
    if [[ "$entry" == *=* ]]; then
      link_one "${entry%%=*}" "${entry#*=}"
    else
      link_one "$REPO/$entry" "$entry"
    fi
  done
done

say
say "Summary: linked=$made already-ok=$ok removed=$removed skipped=$skipped conflicts=$conflicts"
if [[ $conflicts -gt 0 ]]; then
  say "Conflicts were NOT touched. Inspect them, move them yourself, or re-run with --backup."
  exit 1
fi
