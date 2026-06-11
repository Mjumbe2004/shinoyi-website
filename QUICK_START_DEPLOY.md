# 🚀 QUICK START - Deploy in 5 Steps!

## Step 1️⃣: Create AWS Account
- Go to: https://aws.amazon.com
- Click "Create Free Account"
- Add payment method (won't charge for free tier)
- **Time: 5 minutes**

## Step 2️⃣: Install AWS CLI
```bash
# Windows: Download https://awscli.amazonaws.com/AWSCLIV2.msi
# Mac: brew install awscli
# Linux: sudo apt install awscli

# Verify installation
aws --version
```

## Step 3️⃣: Configure AWS Credentials
```bash
aws configure

# Enter these from AWS IAM console:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default format: json
```

## Step 4️⃣: Run Deploy Script (AUTOMATIC! ✨)
```bash
cd backend
chmod +x deploy.sh
./deploy.sh

# This creates everything automatically:
# ✓ EC2 instance (server)
# ✓ RDS database (MySQL)
# ✓ Security groups
# ✓ Generates all config files

# Time: 15-20 minutes
```

## Step 5️⃣: Server Setup
```bash
# SSH into your new server (from deployment_info.txt)
ssh -i school-backend-key.pem ubuntu@<your-public-ip>

# Run setup
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs npm git nginx mysql-client
sudo npm install -g pm2

# Clone, setup, and run
git clone https://github.com/Mjumbe2004/shinoyi-website.git
cd shinoyi-website/backend
npm install
nano .env  # Update with database details from deployment_info.txt

# Create database
mysql -h <db-endpoint> -u admin -p < database/schema.sql

# Start app
pm2 start server.js --name "school-api"
pm2 startup && pm2 save

# Setup reverse proxy
sudo nano /etc/nginx/sites-available/default
# Replace with content from AWS_DEPLOYMENT_GUIDE.md
sudo systemctl restart nginx

# Test
curl http://<your-public-ip>/api/health
```

---

## ✅ YOUR API IS NOW LIVE!

**API URL**: `http://<your-public-ip>`

Update your frontend:
```javascript
const API_URL = 'http://<your-public-ip>';
```

---

## 📊 What You Get (FREE for 12 months!)
- ✅ EC2 Instance (t2.micro) - 750 hours/month
- ✅ RDS MySQL Database - 750 hours/month + 20GB storage
- ✅ 1GB data transfer/month
- After 12 months: ~$23/month

---

## 🆘 Issues?

```bash
# Check if backend is running
pm2 logs school-api

# Check database
mysql -h <endpoint> -u admin -p secondary_school

# Check Nginx
sudo systemctl status nginx

# Check open ports
sudo netstat -tlnp
```

---

## 📁 Important Files
- `school-backend-key.pem` - BACKUP THIS! SSH key
- `deployment_info.txt` - Connection details
- `.env` - Environment variables

---

**Congratulations! Your backend is deployed! 🎉**
