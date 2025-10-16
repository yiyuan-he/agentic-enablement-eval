#!/bin/bash

# Traffic generator script for Express application
PORT=${PORT:-3000}
BASE_URL="http://localhost:${PORT}"

echo "Starting continuous traffic generation to ${BASE_URL}"

while true; do
    echo "[$(date '+%H:%M:%S')] Generating traffic..."

    # Health check
    curl -s "${BASE_URL}/health" > /dev/null

    # API call (S3 buckets)
    curl -s "${BASE_URL}/api/buckets" > /dev/null

    # Sleep between requests
    sleep 2
done
