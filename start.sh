#!/bin/bash

cd ~/video-analysis-system
source venv/bin/activate

# Get the public IP address
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Starting application on http://$PUBLIC_IP"

gunicorn -w 4 -b 0.0.0.0:5000 app:app
