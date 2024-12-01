#!/bin/bash

# Exit on error
set -e

# Setup
echo "Setting up deployment..."
DEPLOYMENT_SOURCE="${DEPLOYMENT_SOURCE:-/home/site/repository}"
DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET:-/home/site/wwwroot}"
PYTHON_VERSION="3.11"
PYTHON_PATH="/usr/local/bin/python${PYTHON_VERSION}"

# Install system dependencies
echo "Installing system dependencies..."
apt-get update
apt-get install -y unixodbc-dev python3-dev python3-pip python3-venv

# Install ODBC Driver
echo "Installing ODBC Driver..."
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Create and activate virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv /home/site/wwwroot/env
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
