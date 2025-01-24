#!/usr/bin/env bash

KEY_NAME="bcitkey"

# Generate a private key
ssh-keygen -t rsa -b 4096 -f ${KEY_NAME}.pem 

# Generate a public key from the private key
ssh-keygen -y -f ${KEY_NAME}.pem > ${KEY_NAME}.pub

# Import the public key to the AWS EC2 instance
aws ec2 import-key-pair --key-name "${KEY_NAME}" --public-key-material file://${KEY_NAME}.pub

if [ $? -eq 0 ]; then
  echo "Key pair '${KEY_NAME}' successfully imported into AWS."
else
  echo "Failed to import key pair '${KEY_NAME}'."
fi