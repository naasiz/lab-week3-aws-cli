#!/bin/bash

# Generate a public key from the private key
ssh-keygen -y -f bcitkey.pem > bcitkey.pub


# Import the public key to the AWS EC2 instance
aws ec2 import-key-pair --key-name "bcitkey" --public-key-material file://bcitkey.pub

if [ $? -eq 0 ]; then
  echo "Key pair '$KEY_NAME' successfully imported into AWS."
else
  echo "Failed to import key pair '$KEY_NAME'."
fi