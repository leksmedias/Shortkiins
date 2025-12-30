#!/bin/bash
# Easy Installation Script for AI Video Generator
# For Ubuntu VPS - Complete Beginner Friendly

set -e  # Exit on any error

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════╗"
echo "║                                                ║"
echo "║       🎬 AI VIDEO GENERATOR INSTALLER 🎬       ║"
echo "║                                                ║"
echo "║           Easy VPS Installation v1.0           ║"
echo "║                                                ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_step() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Check if running as root or with sudo
if [[ $EUID -eq 0 ]]; then
   print_warning "This script should NOT be run as root directly"
   print_info "Please run as: bash install.sh (without sudo)"
   exit 1
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    print_error "sudo is not installed. Please install sudo first."
    exit 1
fi

print_step "📋 STEP 1: Checking System Requirements"

# Check Ubuntu version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_info "OS: $NAME $VERSION"

    if [[ "$ID" != "ubuntu" ]]; then
        print_warning "This script is optimized for Ubuntu. Other distros may work but are not tested."
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    print_warning "Cannot detect OS version. Continuing anyway..."
fi

# Check system resources
print_info "Checking system resources..."
total_mem=$(free -m | awk '/^Mem:/{print $2}')
print_info "RAM: ${total_mem}MB"

if [ "$total_mem" -lt 1500 ]; then
    print_warning "Low memory detected. Recommended: 2GB+ RAM"
fi

print_success "System check complete!"

# Ask for installation directory
print_step "📁 STEP 2: Choose Installation Directory"
echo -e "Where do you want to install the AI Video Generator?"
echo -e "${CYAN}Default: /var/www/Shortkiins${NC}"
read -p "Press Enter for default or type custom path: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-/var/www/Shortkiins}
print_info "Installing to: $INSTALL_DIR"

# Update system
print_step "🔄 STEP 3: Updating System Packages"
print_info "This may take a few minutes..."
sudo apt-get update -qq
print_success "System updated!"

# Install dependencies
print_step "📦 STEP 4: Installing Required Software"

print_info "Installing Python 3..."
sudo apt-get install -y python3 python3-pip python3-venv -qq

print_info "Installing FFmpeg (video processing)..."
sudo apt-get install -y ffmpeg -qq

print_info "Installing Nginx (web server)..."
sudo apt-get install -y nginx -qq

print_info "Installing Git..."
sudo apt-get install -y git -qq

print_success "All dependencies installed!"

# Clone repository
print_step "📥 STEP 5: Downloading Application"

if [ -d "$INSTALL_DIR" ]; then
    print_warning "Directory $INSTALL_DIR already exists"
    read -p "Delete and reinstall? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing old installation..."
        sudo rm -rf "$INSTALL_DIR"
    else
        print_info "Updating existing installation..."
        cd "$INSTALL_DIR"
        sudo git pull
    fi
fi

if [ ! -d "$INSTALL_DIR" ]; then
    print_info "Cloning repository..."
    sudo mkdir -p "$(dirname "$INSTALL_DIR")"
    cd "$(dirname "$INSTALL_DIR")"
    sudo git clone https://github.com/leksmedias/Shortkiins.git "$(basename "$INSTALL_DIR")"
fi

cd "$INSTALL_DIR"
print_success "Application downloaded!"

# Setup Python environment
print_step "🐍 STEP 6: Setting Up Python Environment"

print_info "Creating virtual environment..."
sudo python3 -m venv venv

print_info "Installing Python packages..."
print_warning "This may take 5-10 minutes. Please be patient..."
sudo venv/bin/pip install --upgrade pip -q
sudo venv/bin/pip install -r requirements.txt -q

print_success "Python environment ready!"

# Configure API keys
print_step "🔑 STEP 7: API Keys Configuration"

if [ ! -f "$INSTALL_DIR/.env" ]; then
    sudo cp .env.example .env
fi

echo -e "${CYAN}"
echo "You need API keys to use this application:"
echo ""
echo "1. Groq API (Required) - Free at https://console.groq.com/"
echo "2. Wave Speed AI (Required) - Get at https://wavespeed.ai/"
echo "3. AsyncFlow TTS (Required) - For text-to-speech"
echo "4. Freepik API (Optional) - For image generation"
echo ""
echo "Do you want to configure API keys now?"
echo -e "${NC}"

read -p "Configure now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Enter your API keys (press Enter to skip optional ones):${NC}"

    # Groq API
    echo ""
    read -p "Groq API Key (Required): " GROQ_KEY
    if [ ! -z "$GROQ_KEY" ]; then
        sudo sed -i "s|GROQ_API_KEY=.*|GROQ_API_KEY=$GROQ_KEY|g" .env
        print_success "Groq API key configured"
    fi

    # Wave Speed
    echo ""
    read -p "Wave Speed API Key (Required): " WAVESPEED_KEY
    if [ ! -z "$WAVESPEED_KEY" ]; then
        sudo sed -i "s|WAVESPEED_API_KEY=.*|WAVESPEED_API_KEY=$WAVESPEED_KEY|g" .env
        print_success "Wave Speed API key configured"
    fi

    # AsyncFlow
    echo ""
    read -p "AsyncFlow API Key (Required): " ASYNCFLOW_KEY
    if [ ! -z "$ASYNCFLOW_KEY" ]; then
        sudo sed -i "s|ASYNCFLOW_API_KEY=.*|ASYNCFLOW_API_KEY=$ASYNCFLOW_KEY|g" .env
        print_success "AsyncFlow API key configured"
    fi

    # Freepik (optional)
    echo ""
    read -p "Freepik API Key (Optional - press Enter to skip): " FREEPIK_KEY
    if [ ! -z "$FREEPIK_KEY" ]; then
        sudo sed -i "s|FREEPIK_API_KEY=.*|FREEPIK_API_KEY=$FREEPIK_KEY|g" .env
        print_success "Freepik API key configured"
    fi

    echo ""
    print_success "API keys configured!"
else
    print_warning "Skipping API key configuration"
    print_info "You can configure them later by editing: $INSTALL_DIR/.env"
fi

# Create directories
print_step "📂 STEP 8: Creating Directories"

sudo mkdir -p output temp static
sudo chown -R www-data:www-data "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"

print_success "Directories created!"

# Setup systemd service
print_step "⚙️  STEP 9: Configuring System Service"

# Update paths in service file
sudo sed -i "s|/var/www/Shortkiins|$INSTALL_DIR|g" deployment/video-generator.service

sudo cp deployment/video-generator.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable video-generator

print_success "System service configured!"

# Setup Nginx
print_step "🌐 STEP 10: Configuring Web Server"

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Ask for domain or use IP
echo -e "${CYAN}Do you have a domain name? (e.g., example.com)${NC}"
read -p "Enter domain or press Enter to use IP ($SERVER_IP): " DOMAIN
DOMAIN=${DOMAIN:-$SERVER_IP}

print_info "Configuring for: $DOMAIN"

# Update nginx config
sudo sed -i "s|server_name your-domain.com;|server_name $DOMAIN;|g" deployment/nginx.conf
sudo cp deployment/nginx.conf /etc/nginx/sites-available/video-generator

# Remove default site and enable ours
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/video-generator /etc/nginx/sites-enabled/

# Test nginx config
if sudo nginx -t 2>&1 | grep -q "successful"; then
    print_success "Nginx configuration valid!"
    sudo systemctl reload nginx
else
    print_error "Nginx configuration has errors"
    sudo nginx -t
fi

# Configure firewall
print_step "🔒 STEP 11: Configuring Firewall"

if command -v ufw &> /dev/null; then
    print_info "Setting up firewall rules..."

    # Check if SSH port is open
    SSH_PORT=$(sudo netstat -tlnp 2>/dev/null | grep sshd | awk '{print $4}' | grep -oP ':\K[0-9]+' | head -1)
    SSH_PORT=${SSH_PORT:-22}

    sudo ufw allow $SSH_PORT/tcp comment 'SSH' 2>/dev/null || true
    sudo ufw allow 80/tcp comment 'HTTP' 2>/dev/null || true
    sudo ufw allow 443/tcp comment 'HTTPS' 2>/dev/null || true

    # Enable firewall if not already enabled
    echo "y" | sudo ufw enable 2>/dev/null || true

    print_success "Firewall configured!"
else
    print_warning "UFW firewall not found. Skipping firewall setup."
fi

# Start service
print_step "🚀 STEP 12: Starting Application"

sudo systemctl start video-generator

# Wait a moment for service to start
sleep 3

# Check if service is running
if sudo systemctl is-active --quiet video-generator; then
    print_success "Application started successfully!"
else
    print_error "Service failed to start"
    print_info "Checking logs..."
    sudo journalctl -u video-generator -n 20 --no-pager
    exit 1
fi

# Final messages
print_step "🎉 INSTALLATION COMPLETE!"

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════╗"
echo "║                                                ║"
echo "║            ✅ INSTALLATION SUCCESS! ✅          ║"
echo "║                                                ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📍 ACCESS YOUR APPLICATION:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "🌐 Web Interface:  ${GREEN}http://$DOMAIN${NC}"
echo -e "📚 API Docs:       ${GREEN}http://$DOMAIN/docs${NC}"
echo -e "💚 Health Check:   ${GREEN}http://$DOMAIN/api/health${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🛠️  USEFUL COMMANDS:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "📊 View logs:           ${YELLOW}sudo journalctl -u video-generator -f${NC}"
echo -e "🔄 Restart service:     ${YELLOW}sudo systemctl restart video-generator${NC}"
echo -e "⏹️  Stop service:        ${YELLOW}sudo systemctl stop video-generator${NC}"
echo -e "✅ Check status:        ${YELLOW}sudo systemctl status video-generator${NC}"
echo -e "⚙️  Edit config:         ${YELLOW}sudo nano $INSTALL_DIR/.env${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔐 SECURITY RECOMMENDATIONS:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "1. ${YELLOW}Setup SSL/HTTPS:${NC}"
echo -e "   sudo apt install certbot python3-certbot-nginx"
echo -e "   sudo certbot --nginx -d $DOMAIN"
echo ""
echo -e "2. ${YELLOW}Configure API keys if not done:${NC}"
echo -e "   sudo nano $INSTALL_DIR/.env"
echo -e "   sudo systemctl restart video-generator"
echo ""
echo -e "3. ${YELLOW}Keep system updated:${NC}"
echo -e "   sudo apt update && sudo apt upgrade"
echo ""

if [ -z "$GROQ_KEY" ] || [ -z "$WAVESPEED_KEY" ] || [ -z "$ASYNCFLOW_KEY" ]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}⚠️  IMPORTANT: API KEYS NOT CONFIGURED!${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}The application won't work without API keys!${NC}"
    echo -e "Please configure them now:"
    echo -e "1. ${CYAN}sudo nano $INSTALL_DIR/.env${NC}"
    echo -e "2. Add your API keys"
    echo -e "3. ${CYAN}sudo systemctl restart video-generator${NC}"
    echo ""
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📖 NEED HELP?${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "📚 Full documentation: ${GREEN}$INSTALL_DIR/DEPLOYMENT.md${NC}"
echo -e "🐛 Report issues: ${GREEN}https://github.com/leksmedias/Shortkiins/issues${NC}"
echo ""

echo -e "${GREEN}Thank you for using AI Video Generator! 🎬${NC}"
echo ""
