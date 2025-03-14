#!/bin/bash

# Set the URL of your dotfiles Git repository
DOTFILES_REPO="https://github.com/abraxoxs/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Clone the dotfiles repository
echo "Cloning dotfiles repository from $DOTFILES_REPO..."
if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles directory already exists. Pulling the latest changes..."
    cd "$DOTFILES_DIR" && git pull
else
    echo "Dotfiles directory not found. Cloning..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# List of files to symlink or copy
#DOTFILES=(".gitconfig" ".bashrc" ".vimrc")
DOTFILES=(".gitconfig")

# Loop over each file and replace it
for FILE in "${DOTFILES[@]}"; do
    SRC="$DOTFILES_DIR/$FILE"
    DEST="$HOME/$FILE"
    
    if [ -e "$DEST" ]; then
        echo "Replacing existing file $DEST with $SRC"
        mv "$DEST" "$DEST.bak"  # Backup the existing file
    fi

    echo "Symlinking $SRC to $DEST"
    ln -sf "$SRC" "$DEST"
done

# Optional: Source the new files (e.g., for .bashrc)
echo "Sourcing new .bashrc (if applicable)..."
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

echo "Dotfiles setup complete!"
