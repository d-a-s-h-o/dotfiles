# 🧙 Dasho's Dotfiles

My personal dotfiles, managed by a magical interactive wizard.

This repository contains my personal configuration for `zsh`, `git`, `nvim`, and other tools. It's designed to be portable and easy to set up on any new machine.

> **Pro tip**: My single init.lua file for Neovim is [here](config/nvim/init.lua) and it is awesome. I personally really like the look of it and it is very fast, yet inuitive for newer users.

## Quick Start

The easiest way to use this repository is with the interactive wizard. It handles everything from initial setup to backups and git operations.

Just a warning though, it can be a little broken now and then. I might improve it soon but if you want to, feel free to open an issue or PR!

```bash
# Clone the repo (if you haven't already)
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# Run the wizard!
just wizard
```

The wizard will guide you through:
-   **Bootstrapping** a new machine (installing Homebrew, packages, etc.)
-   **Backing up** installed packages and secrets.
-   **Restoring** secrets from an encrypted archive.
-   **Linking** all configuration files to their correct locations.
-   **Managing** this git repository with a friendly UI.

## 🔐 Secrets Management

This repository has a built-in workflow for securely managing sensitive files like GPG keys, SSH keys, and other credentials using `age` encryption.

### How it Works

1.  **Backup (`just wizard` -> `Backup secrets`)**:
    -   The `backup-secrets` script gathers credentials from common locations:
        -   GPG keys (`~/.gnupg`)
        -   SSH keys (`~/.ssh`)
        -   `age` identities (`~/.config/age/keys.txt`)
        -   `skate` database entries
        -   Oh-My-Zsh custom configurations (`~/.oh-my-zsh/custom`)
    -   It bundles them into a `tar.gz` archive.
    -   It encrypts this archive using `age` into a file like `private/keys-YYYYMMDD.tar.gz.age`.

2.  **Storage**:
    -   The encrypted archive is saved in the `private/` directory.
    -   **⚠️ IMPORTANT**: The `private/` directory is intended to be committed to a **private Git repository only**. Do not expose your encrypted secrets on a public repository.

3.  **Restore (`just wizard` -> `Restore secrets`)**:
    -   The `restore-secrets` script prompts you to choose an archive from the `private/` directory.
    -   It decrypts the archive using your `age` identity.
    -   It restores the files to their original locations on the new machine.

This system allows you to safely version control your secrets and easily provision a new machine with all your configurations and credentials.
