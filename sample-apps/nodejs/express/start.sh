#!/bin/bash
set -e

# Install Node.js dependencies
npm install

# Set default environment variables
export PORT=${PORT:-3000}
export SERVICE_NAME=${SERVICE_NAME:-nodejs-express-app}

# Start the Express application
node app.js
