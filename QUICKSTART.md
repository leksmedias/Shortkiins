# 🚀 Quick Start Guide - Install in 5 Minutes

Ultra-simple guide to get your AI Video Generator running on Ubuntu VPS.

## ✨ One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/leksmedias/Shortkiins/main/install.sh | bash
```

**That's it!** The script will:
- ✅ Install all dependencies automatically
- ✅ Setup the application
- ✅ Configure web server
- ✅ Start the service
- ✅ Set up firewall

---

## 📋 Before You Start

You need:
- ✅ Ubuntu VPS (20.04 or newer)
- ✅ Sudo/root access
- ✅ 2GB+ RAM
- ✅ API Keys (free to get):
  - [Inworld AI TTS](https://studio.inworld.ai/) - Professional voice synthesis (Default)
  - [Groq API](https://console.groq.com/) - Free AI for scene division
  - [Wave Speed AI](https://wavespeed.ai/) - Fast image generation

---

## 🎯 Method 1: Automatic Installation (Recommended)

### Step 1: SSH into Your VPS

```bash
ssh root@your-server-ip
# or
ssh username@your-server-ip
```

### Step 2: Download and Run Installer

```bash
# Download install script
wget https://raw.githubusercontent.com/leksmedias/Shortkiins/main/install.sh

# Make it executable
chmod +x install.sh

# Run it!
bash install.sh
```

### Step 3: Follow the Interactive Prompts

The script will ask you:
1. ✅ Installation directory (default: `/var/www/Shortkiins`)
2. ✅ Your API keys
3. ✅ Domain name or use IP address

### Step 4: Done! 🎉

Access your app at: `http://your-server-ip`

---

## 🛠️ Method 2: Manual Installation (3 Commands)

If you prefer manual control:

```bash
# 1. Clone repository
cd /var/www
sudo git clone https://github.com/leksmedias/Shortkiins.git
cd Shortkiins

# 2. Run deployment script
chmod +x deployment/deploy.sh
sudo ./deployment/deploy.sh

# 3. Configure API keys
sudo nano .env
# Add your keys, save and exit
sudo systemctl restart video-generator
```

---

## 🔑 Getting API Keys (Free)

### Inworld AI TTS (Required - Default Voice)
1. Go to https://studio.inworld.ai/
2. Sign up for free account
3. Navigate to API settings
4. Get your **base64 authentication credential**
5. Copy the credential (looks like a long encoded string)

### Groq API (Required - Scene Division)
1. Go to https://console.groq.com/
2. Sign up (free)
3. Click "API Keys"
4. Create new key
5. Copy the key (starts with `gsk_`)

### Wave Speed AI (Required - Image Generation)
1. Visit https://wavespeed.ai/
2. Sign up
3. Get API key from dashboard
4. Copy the key

---

## 📝 Configure API Keys After Installation

```bash
# Edit configuration file
sudo nano /var/www/Shortkiins/.env

# Add your keys (3 required):
INWORLD_API_KEY=your_base64_credential_here
GROQ_API_KEY=gsk_your_groq_key_here
WAVESPEED_API_KEY=your_wavespeed_key_here

# Save (Ctrl+X, Y, Enter)

# Restart service
sudo systemctl restart video-generator
```

---

## ✅ Verify Installation

### Check if service is running:
```bash
sudo systemctl status video-generator
```

Should show: `active (running)` in green

### Test the web interface:
```bash
# Get your server IP
hostname -I

# Visit in browser
http://your-server-ip
```

### Check API health:
```bash
curl http://localhost:8000/api/health
```

Should return: `{"status":"healthy",...}`

---

## 🎬 Using Your Video Generator

1. **Open in browser**: `http://your-server-ip`
2. **Enter your script** in the text box
3. **Choose settings**:
   - Aspect ratio: 16:9 (YouTube) or 9:16 (TikTok)
   - Image provider: Wave Speed (recommended)
   - Scene duration: 3 seconds (default)
4. **Click "Generate Video"**
5. **Wait** - it will show real-time progress
6. **Download** your video when complete!

---

## 🚨 Troubleshooting

### Service won't start?
```bash
# Check logs
sudo journalctl -u video-generator -n 50

# Common issue: API keys not set
sudo nano /var/www/Shortkiins/.env
sudo systemctl restart video-generator
```

### Can't access website?
```bash
# Check if service is running
sudo systemctl status video-generator

# Check nginx
sudo systemctl status nginx

# Check firewall
sudo ufw status
sudo ufw allow 80
```

### "API key not configured" error?
```bash
# Edit .env file
sudo nano /var/www/Shortkiins/.env

# Make sure keys are set (no quotes needed):
GROQ_API_KEY=gsk_abc123...
WAVESPEED_API_KEY=ws_xyz789...

# Restart
sudo systemctl restart video-generator
```

---

## 🔐 Enable HTTPS (SSL)

After basic setup works:

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get free SSL certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com

# Done! Now access via: https://yourdomain.com
```

---

## 🎯 Quick Commands Reference

```bash
# View live logs
sudo journalctl -u video-generator -f

# Restart service
sudo systemctl restart video-generator

# Stop service
sudo systemctl stop video-generator

# Start service
sudo systemctl start video-generator

# Check status
sudo systemctl status video-generator

# Edit configuration
sudo nano /var/www/Shortkiins/.env

# Update application
cd /var/www/Shortkiins
sudo git pull
sudo systemctl restart video-generator
```

---

## 📊 System Requirements

**Minimum:**
- 2GB RAM
- 2 CPU cores
- 20GB storage
- Ubuntu 20.04+

**Recommended:**
- 4GB RAM
- 4 CPU cores
- 50GB storage
- Ubuntu 22.04

---

## 💡 Tips for Beginners

1. **Start with short scripts** (30-60 seconds) to test
2. **Use Wave Speed** for fastest image generation
3. **16:9 aspect ratio** works for most use cases
4. **Check logs** if something doesn't work: `sudo journalctl -u video-generator -f`
5. **Keep API keys secret** - never share them!

---

## 🎓 What Gets Installed?

The automatic installer sets up:
- ✅ Python 3 + Virtual Environment
- ✅ FFmpeg (video processing)
- ✅ Nginx (web server)
- ✅ Git (version control)
- ✅ All Python dependencies
- ✅ Systemd service (auto-starts on boot)
- ✅ Firewall rules
- ✅ Application files

---

## 🆘 Still Need Help?

1. **Read full docs**: `/var/www/Shortkiins/DEPLOYMENT.md`
2. **Check logs**: `sudo journalctl -u video-generator -f`
3. **Test API**: `curl http://localhost:8000/api/health`
4. **Report issues**: https://github.com/leksmedias/Shortkiins/issues

---

## 🎉 You're Done!

Congratulations! Your AI Video Generator is now running.

**Next Steps:**
1. ✅ Generate your first video
2. ✅ Set up SSL/HTTPS
3. ✅ Point your domain to the server
4. ✅ Share with your team

**Access your app at:** `http://your-server-ip`

Happy video generating! 🎬✨
