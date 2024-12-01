#!/bin/bash

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Set up environment variables
export DEPLOYMENT_SOURCE="${DEPLOYMENT_SOURCE:-/home/site/repository}"
export DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET:-/home/site/wwwroot}"
export PYTHON_VERSION="3.11"
export PYTHON_HOME="/opt/python/${PYTHON_VERSION}/bin"
export PATH="$PYTHON_HOME:$PATH"

# Install Python dependencies
echo "Installing Python dependencies..."
$PYTHON_HOME/python -m pip install -r requirements.txt

# Collect static files
echo "Collecting static files..."
$PYTHON_HOME/python manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
$PYTHON_HOME/python manage.py migrate --noinput

echo "Deployment completed successfully!"
