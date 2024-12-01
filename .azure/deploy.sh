#!/bin/bash

# Exit on error
set -e

# Setup
echo "Setting up deployment..."
DEPLOYMENT_SOURCE="${DEPLOYMENT_SOURCE:-/home/site/repository}"
DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET:-/home/site/wwwroot}"

# Create and activate virtual environment
echo "Setting up Python virtual environment..."
python -m venv /home/site/wwwroot/env
source /home/site/wwwroot/env/bin/activate

# Upgrade pip and install dependencies
echo "Installing Python dependencies..."
python -m pip install --upgrade pip
pip install -r requirements.txt

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

echo "Deployment completed successfully!"
