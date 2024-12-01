#!/bin/bash

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Install Python dependencies
echo "Installing Python dependencies..."
/usr/bin/python3 -m pip install -r requirements.txt

# Collect static files
echo "Collecting static files..."
/usr/bin/python3 manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
/usr/bin/python3 manage.py migrate --noinput

echo "Deployment completed successfully!"
