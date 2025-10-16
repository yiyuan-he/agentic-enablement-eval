#!/bin/bash
set -e

# Set default environment variables
export PORT=${PORT:-5000}
export SERVICE_NAME=${SERVICE_NAME:-dotnet-aspnetcore-app}
export ASPNETCORE_URLS="http://0.0.0.0:${PORT}"

# Build and run the .NET application
dotnet run
