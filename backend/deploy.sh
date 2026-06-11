#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}AWS Deployment Script${NC}"
echo -e "${YELLOW}=====================================${NC}\n"

# Configuration
AWS_REGION="us-east-1"
INSTANCE_TYPE="t2.micro"
KEY_NAME="school-backend-key"
SECURITY_GROUP="school-backend-sg"
DB_INSTANCE="school-database"
DB_USERNAME="admin"
DB_PASSWORD="SchoolDB@123456"
AMI_ID="ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS

# Step 1: Create Key Pair
echo -e "${YELLOW}Step 1: Creating key pair...${NC}"
aws ec2 create-key-pair --key-name $KEY_NAME --region $AWS_REGION --output text > $KEY_NAME.pem 2>/dev/null
if [ $? -eq 0 ]; then
    chmod 400 $KEY_NAME.pem
    echo -e "${GREEN}✓ Key pair created: $KEY_NAME.pem${NC}"
else
    echo -e "${YELLOW}⚠ Key pair might already exist${NC}"
fi

# Step 2: Create Security Group
echo -e "\n${YELLOW}Step 2: Creating security group...${NC}"
SG_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP \
    --description "Security group for school backend" \
    --region $AWS_REGION \
    --output text 2>/dev/null)

if [ -z "$SG_ID" ]; then
    SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$SECURITY_GROUP --region $AWS_REGION --output text --query 'SecurityGroups[0].GroupId')
    echo -e "${YELLOW}⚠ Using existing security group: $SG_ID${NC}"
else
    echo -e "${GREEN}✓ Security group created: $SG_ID${NC}"
fi

# Step 3: Add Security Group Rules
echo -e "\n${YELLOW}Step 3: Adding security group rules...${NC}"

# SSH
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION 2>/dev/null && echo -e "${GREEN}✓ SSH (22) allowed${NC}"

# HTTP
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION 2>/dev/null && echo -e "${GREEN}✓ HTTP (80) allowed${NC}"

# HTTPS
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION 2>/dev/null && echo -e "${GREEN}✓ HTTPS (443) allowed${NC}"

# API Port
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 5000 \
    --cidr 0.0.0.0/0 \
    --region $AWS_REGION 2>/dev/null && echo -e "${GREEN}✓ API (5000) allowed${NC}"

# Step 4: Launch EC2 Instance
echo -e "\n${YELLOW}Step 4: Launching EC2 instance...${NC}"
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --region $AWS_REGION \
    --monitoring Enabled=true \
    --output text \
    --query 'Instances[0].InstanceId')

echo -e "${GREEN}✓ Instance launched: $INSTANCE_ID${NC}"
echo -e "${YELLOW}Waiting for instance to be running (this may take 2-3 minutes)...${NC}"

aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $AWS_REGION
echo -e "${GREEN}✓ Instance is running${NC}"

# Get Public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $AWS_REGION \
    --output text \
    --query 'Reservations[0].Instances[0].PublicIpAddress')

echo -e "${GREEN}✓ Public IP: $PUBLIC_IP${NC}"

# Step 5: Create RDS Database
echo -e "\n${YELLOW}Step 5: Creating RDS MySQL database...${NC}"
aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.28 \
    --master-username $DB_USERNAME \
    --master-user-password $DB_PASSWORD \
    --allocated-storage 20 \
    --storage-type gp2 \
    --publicly-accessible \
    --backup-retention-period 7 \
    --region $AWS_REGION 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ RDS instance created: $DB_INSTANCE${NC}"
    echo -e "${YELLOW}Waiting for database to be available (this may take 10-15 minutes)...${NC}"
    
    aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE --region $AWS_REGION
    echo -e "${GREEN}✓ Database is available${NC}"
else
    echo -e "${YELLOW}⚠ RDS instance might already exist or there was an error${NC}"
fi

# Get RDS Endpoint
DB_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier $DB_INSTANCE \
    --region $AWS_REGION \
    --output text \
    --query 'DBInstances[0].Endpoint.Address')

echo -e "${GREEN}✓ Database endpoint: $DB_ENDPOINT${NC}"

# Step 6: Generate Deployment Summary
echo -e "\n${YELLOW}=====================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${YELLOW}=====================================${NC}\n"

echo -e "${YELLOW}SSH CONNECTION:${NC}"
echo -e "ssh -i $KEY_NAME.pem ubuntu@$PUBLIC_IP\n"

echo -e "${YELLOW}ENVIRONMENT VARIABLES:${NC}"
echo -e "DB_HOST=$DB_ENDPOINT"
echo -e "DB_USER=$DB_USERNAME"
echo -e "DB_PASSWORD=$DB_PASSWORD"
echo -e "DB_NAME=secondary_school\n"

echo -e "${YELLOW}API ENDPOINT:${NC}"
echo -e "http://$PUBLIC_IP\n"

echo -e "${YELLOW}NEXT STEPS:${NC}"
echo -e "1. SSH into your server: ssh -i $KEY_NAME.pem ubuntu@$PUBLIC_IP"
echo -e "2. Run the server setup commands (see documentation)"
echo -e "3. Update your .env file with the database credentials"
echo -e "4. Deploy your application\n"

echo -e "${YELLOW}Save this information to a safe place!${NC}"

# Save to file
cat > deployment_info.txt << EOF
AWS Deployment Information
==========================

Instance ID: $INSTANCE_ID
Public IP: $PUBLIC_IP
Key File: $KEY_NAME.pem
Region: $AWS_REGION

SSH Command:
ssh -i $KEY_NAME.pem ubuntu@$PUBLIC_IP

Database:
Endpoint: $DB_ENDPOINT
Username: $DB_USERNAME
Password: $DB_PASSWORD
Database Name: secondary_school

Important: Keep this file safe and secure!
EOF

echo -e "\n${GREEN}✓ Deployment info saved to: deployment_info.txt${NC}"
