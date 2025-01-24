#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket_name>"
    exit 1
fi

bucket_name=$1

if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
    echo "Bucket $bucket_name already exists."
else
    aws s3api create-bucket --bucket "$bucket_name" --region us-west-2 \
    --create-bucket-configuration LocationConstraint=us-west-2
    echo "Bucket $bucket_name created successfully."
fi
