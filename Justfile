# Justfile
# ------------------------------------------------------------------------------
# Dotfiles + secrets workflow
#
# Quick start:
#   just bootstrap
#   just backup
#   just backup-secrets
#
# Notes:
# - This repo is intended to be cloned to: ~/.dotfiles
# - Encrypted archives should be committed ONLY to a private remote
# ------------------------------------------------------------------------------

default := "help"

dotdir := env_var_or_default("DOTFILES_DIR", "~/.dotfiles")
private_dir := "private"

help:
  @echo ""
  @echo "Dotfiles & Secrets Commands"
  @echo "--------------------------"
  @echo "wizard             🧙 Interactive wizard for all operations (recommended!)"
  @echo "bootstrap          Install Homebrew (if needed), brew bundle install, link configs."
  @echo "backup             Update Brewfile and brew/leaves.txt from current machine."
  @echo "backup-secrets      Create encrypted archive (GPG/SSH/age/Skate) into private/."
  @echo "restore-secrets A   Decrypt and restore from archive A."
  @echo "link               Symlink dotfiles into expected locations (~/.zshrc, ~/.config/direnv/, etc)."
  @echo "check              Verify core tools exist (direnv, skate, age, just)."
  @echo ""
  @echo "When to use:"
  @echo "- RECOMMENDED:      just wizard (interactive, guided experience)"
  @echo "- On a NEW machine: just bootstrap && just restore-secrets private/keys-YYYYMMDD.tar.gz.age"
  @echo "- After changes:    just backup && git commit"
  @echo "- Periodically:     just backup-secrets && git commit (private repo!)"
  @echo ""

check:
  @command -v direnv >/dev/null 2>&1 || (echo "Missing: direnv" && exit 1)
  @command -v skate  >/dev/null 2>&1 || (echo "Missing: skate"  && exit 1)
  @command -v age    >/dev/null 2>&1 || (echo "Missing: age"    && exit 1)
  @command -v just   >/dev/null 2>&1 || (echo "Missing: just"   && exit 1)
  @echo "OK"

# 🧙 Interactive wizard - the magical way to manage dotfiles
wizard:
  @zsh {{justfile_directory()}}/bin/wizard

# Alias for wizard
w: wizard
easy: wizard

# Link configs into expected locations.
link:
  @mkdir -p ~/.config/direnv
  @mkdir -p ~/.config/git
  @mkdir -p ~/.config/nvim
  @mkdir -p ~/.config/redbrick

  @ln -snf {{justfile_directory()}}/zsh/zshrc ~/.zshrc
  @echo "Linked ~/.zshrc"
  @ln -snf {{justfile_directory()}}/config/direnv/direnvrc ~/.config/direnv/direnvrc
  @echo "Linked ~/.config/direnv/direnvrc"
  @ln -snf {{justfile_directory()}}/config/git/config ~/.gitconfig
  @echo "Linked ~/.gitconfig"
  @ln -snf {{justfile_directory()}}/config/git/config ~/.config/git/config
  @echo "Linked ~/.config/git/config"
  @ln -snf {{justfile_directory()}}/config/nvim/init.lua ~/.config/nvim/init.lua
  @echo "Linked ~/.config/nvim/init.lua"
  @ln -snf {{justfile_directory()}}/config/redbrick ~/.config/redbrick
  @echo "Linked ~/.config/redbrick/*"
  @echo "Linked all dotfiles."

# Full new-machine setup.
bootstrap:
  @bash {{justfile_directory()}}/bin/bootstrap

# Update Brewfile + leaves list.
backup:
  @bash {{justfile_directory()}}/bin/backup

# Create encrypted backup archive in private/
backup-secrets:
  @mkdir -p {{justfile_directory()}}/{{private_dir}}
  @bash {{justfile_directory()}}/bin/backup-secrets

# Restore from an encrypted archive
restore-secrets archive:
  @bash {{justfile_directory()}}/bin/restore-secrets {{archive}}

