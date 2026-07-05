#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/flask-userdata.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "========== Flask Server Provisioning Started =========="

##############################################
# Update System
##############################################

apt-get update -y
apt-get upgrade -y

##############################################
# Install Required Packages
##############################################

apt-get install -y \
git \
python3 \
python3-pip \
python3-venv \
python3-dev \
build-essential \
nginx \
curl

##############################################
# Create Application User (Optional)
##############################################

id ubuntu || useradd -m ubuntu

##############################################
# Application Directory
##############################################

APP_DIR="/home/ubuntu/flask_Practice"

##############################################
# Clone Repository
##############################################

if [ ! -d "$APP_DIR" ]; then
    git clone https://github.com/sairamraavi/flask_Practice.git "$APP_DIR"
fi

cd "$APP_DIR"

##############################################
# Create Virtual Environment
##############################################

python3 -m venv venv

source venv/bin/activate

pip install --upgrade pip

pip install -r requirements.txt

##############################################
# Create .env File
##############################################

cat > .env <<'EOF'
MONGO_URI="mongodb+srv://sairamraavi1_db_user:iB1v2eqabogBtx0T@sairamraavi.ts0wmlt.mongodb.net/flask-app"
EOF

chown ubuntu:ubuntu .env
chmod 600 .env

##############################################
# Install Gunicorn
##############################################

pip install gunicorn

##############################################
# Create systemd Service
##############################################

cat > /etc/systemd/system/flask-app.service <<EOF
[Unit]
Description=Flask Application
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
ExecStart=$APP_DIR/venv/bin/gunicorn --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

##############################################
# Configure Nginx Reverse Proxy
##############################################

cat > /etc/nginx/sites-available/flask-app <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/

nginx -t

systemctl restart nginx
systemctl enable nginx

##############################################
# Start Flask Application
##############################################

systemctl daemon-reload
systemctl enable flask-app
systemctl restart flask-app

##############################################
# Permissions
##############################################

chown -R ubuntu:ubuntu "$APP_DIR"

##############################################
# Installation Summary
##############################################

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

cat <<EOF >/home/ubuntu/flask-server-info.txt
==========================================
Flask Server Installed Successfully
==========================================

Repository:
https://github.com/sairamraavi/flask_Practice

Application Directory:
$APP_DIR

Flask URL:
http://$PUBLIC_IP

Gunicorn:
systemctl status flask-app

Nginx:
systemctl status nginx

Logs:
journalctl -u flask-app -f

==========================================
EOF

chown ubuntu:ubuntu /home/ubuntu/flask-server-info.txt

echo "========== Flask Provisioning Completed =========="