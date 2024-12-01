#!/bin/bash

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

echo "Deployment completed successfully!"
