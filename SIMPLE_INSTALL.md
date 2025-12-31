# Simple VPS Installation (No Script Needed)

If the install script download fails, here's a manual step-by-step installation:

## Quick Installation Commands

```bash
# 1. Install system dependencies
sudo apt update
sudo apt install -y python3 python3-pip python3-venv ffmpeg git

# 2. Clone the repository (use HTTPS)
cd ~
git clone -b claude/video-generator-pipeline-fal1T https://github.com/leksmedias/Shortkiins.git
cd Shortkiins

# OR download the feature branch directly
cd ~
wget https://github.com/leksmedias/Shortkiins/archive/refs/heads/claude/video-generator-pipeline-fal1T.zip
unzip claude/video-generator-pipeline-fal1T.zip
cd Shortkiins-claude-video-generator-pipeline-fal1T

# 3. Create Python virtual environment
python3 -m venv venv

# 4. Install Python packages
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 5. Set up configuration
cp .env.example .env
nano .env  # Edit and add your API keys

# 6. Create directories
mkdir -p output temp static

# 7. Test the installation
python main.py --help

# 8. Run the web interface
python api.py
```

## Required API Keys

Edit `.env` file and add:

1. **INWORLD_API_KEY** - Get base64 credential from https://studio.inworld.ai/
2. **GROQ_API_KEY** - Free at https://console.groq.com/
3. **WAVESPEED_API_KEY** - Get at https://wavespeed.ai/

## Running

```bash
# Activate virtual environment
source venv/bin/activate

# Start web server
python api.py

# Access at: http://YOUR_SERVER_IP:8000
```

## For Production with Nginx

After basic installation works:

```bash
# Copy service file
sudo cp deployment/video-generator.service /etc/systemd/system/
sudo systemctl enable video-generator
sudo systemctl start video-generator

# Configure Nginx
sudo cp deployment/nginx.conf /etc/nginx/sites-available/video-generator
sudo ln -s /etc/nginx/sites-available/video-generator /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

