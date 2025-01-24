#!/usr/bin/env bash

# Check if the number of command-line arguments is correct
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket_name>"
    exit 1
fi

bucket_name=$1

# Validate bucket name
if [[ ! "$bucket_name" =~ ^[a-z0-9.-]{3,63}$ ]]; then
    echo "Error: Bucket name '$bucket_name' is invalid. Must be 3-63 characters, lowercase, and contain only letters, numbers, hyphens, and periods."
    exit 1
fi

# Check if the bucket exists
if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
    echo "Bucket $bucket_name already exists."
else
    aws s3api create-bucket --bucket "$bucket_name" --region us-west-2 \
    --create-bucket-configuration LocationConstraint=us-west-2
    if [ $? -eq 0 ]; then
        echo "Bucket $bucket_name created successfully."
    else
        echo "Failed to create bucket $bucket_name."
        exit 1
    fi
fi
