#!/bin/bash

# Predefined variables
KEY_NAME="bcitkey"
PRIVATE_KEY="$KEY_NAME.pem"
PUBLIC_KEY="$KEY_NAME.pub"
AWS_REGION="us-west-2" # Change to your desired AWS region
PASSPHRASE=""          # Empty passphrase for the private key

# Generate private key if it doesn't exist
if [ ! -f "$PRIVATE_KEY" ]; then
  echo "Private key not found. Generating key pair..."
  ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY" -C "user@TristansPc" -N "$PASSPHRASE" <<< ""
  if [ $? -ne 0 ]; then
    echo "Failed to generate the key pair."
    exit 1
  fi
else
  echo "Private key '$PRIVATE_KEY' already exists."
fi

# Generate public key if it doesn't exist
if [ ! -f "$PUBLIC_KEY" ]; then
  echo "Public key not found. Generating from private key..."
  ssh-keygen -y -f "$PRIVATE_KEY" > "$PUBLIC_KEY"
  if [ $? -ne 0 ]; then
    echo "Failed to generate the public key."
    exit 1
  fi
fi

# Configure AWS CLI region (optional but useful for automation)
aws configure set region "$AWS_REGION"

# Import the public key to AWS EC2
echo "Importing key pair '$KEY_NAME' to AWS..."
aws ec2 import-key-pair --key-name "$KEY_NAME" --public-key-material fileb://"$PUBLIC_KEY"

if [ $? -eq 0 ]; then
  echo "Key pair '$KEY_NAME' successfully imported into AWS."
else
  echo "Failed to import key pair '$KEY_NAME'."
fi

