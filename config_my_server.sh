#!/bin/bash

# Color codes for echoing with colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No color

# Set the URL of your dotfiles Git repository
DOTFILES_REPO="https://github.com/abraxoxs/dotfiles.git"  # Replace with your actual repository URL
DOTFILES_DIR="$HOME/dotfiles"

# Function to echo in color
echo_step() {
    echo -e "${BLUE}$1${NC}"
}

echo_success() {
    echo -e "${GREEN}$1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}$1${NC}"
}

echo_error() {
    echo -e "${RED}$1${NC}"
}

# Clone the dotfiles repository
echo_step "Cloning dotfiles repository from $DOTFILES_REPO..."
if [ -d "$DOTFILES_DIR" ]; then
    echo_success "Dotfiles directory already exists. Pulling the latest changes..."
    cd "$DOTFILES_DIR" && git pull
else
    echo_success "Dotfiles directory not found. Cloning..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# List of files to symlink or copy
DOTFILES=(".gitconfig" ".bashrc" ".vimrc")

# Loop over each file and replace it
for FILE in "${DOTFILES[@]}"; do
    SRC="$DOTFILES_DIR/$FILE"
    DEST="$HOME/$FILE"
    
    if [ -e "$DEST" ]; then
        echo_warning "Replacing existing file $DEST with $SRC"
        mv "$DEST" "$DEST.bak"  # Backup the existing file
    fi

    echo_step "Symlinking $SRC to $DEST"
    ln -sf "$SRC" "$DEST"
done

# Optional: Source the new files (e.g., for .bashrc)
echo_step "Sourcing new .bashrc (if applicable)..."
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

echo_success "Dotfiles setup complete!"
