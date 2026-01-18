#!/bin/bash

# Update system and install dependencies for Amazon Linux 2
echo "Updating system and installing dependencies for Amazon Linux 2..."
sudo yum update -y
sudo yum install -y python3 python3-pip nginx git

# Create project directory
echo "Creating project directory..."
mkdir -p ~/video-analysis-system
cd ~/video-analysis-system

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install flask boto3 python-dotenv gunicorn

# Setup Nginx
echo "Setting up Nginx..."
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled

# Add include directive to nginx.conf if not already present
if ! grep -q "sites-enabled" /etc/nginx/nginx.conf; then
    sudo sed -i '/http {/a\    include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
fi

sudo cp nginx.conf /etc/nginx/sites-available/video-analysis
sudo ln -sf /etc/nginx/sites-available/video-analysis /etc/nginx/sites-enabled/

# Create nginx user and set permissions
sudo useradd nginx || true
sudo chown -R nginx:nginx /var/log/nginx
sudo chown -R nginx:nginx /var/lib/nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Make scripts executable
chmod +x start.sh

# Open port 80 in firewall if needed
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "Setup completed! Run './start.sh' to start the application."
echo "Your application will be available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
