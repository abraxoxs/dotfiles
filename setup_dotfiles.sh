#!/bin/bash
set -e

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

echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com | sudo sh

echo "➕ Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER

echo "🔧 Installing Docker Compose plugin..."
sudo apt install docker-compose-plugin -y

echo "🌱 Installing Git..."
sudo apt install git -y

echo "💻 Installing Zsh..."
sudo apt install zsh -y

echo "💡 Installing Oh My Zsh..."
# Use unattended install to avoid user prompt
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "⚙️ Changing default shell to Zsh for user '$USER'..."
chsh -s $(which zsh)

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
DOTFILES=(".gitconfig" ".bashrc" ".vimrc" ".zshrc")

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


echo "✅ All done!"
echo "⚠️ Please reboot your system to apply group and shell changes."
echo "You can do this now by running: sudo reboot"
