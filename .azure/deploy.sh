#!/bin/bash

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Set up Python paths
export PATH=/usr/local/python/3.11/bin:$PATH
export PYTHONPATH=$DEPLOYMENT_TARGET

# Install Python dependencies
echo "Installing Python dependencies..."
python -m pip install -r requirements.txt

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

echo "Deployment completed successfully!"
