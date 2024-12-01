#!/bin/bash

# Set up environment variables
export HOME=/home/site/wwwroot
export DEPLOYMENT_SOURCE=/home/site/repository
export DEPLOYMENT_TARGET=/home/site/wwwroot

# Copy repository contents to wwwroot
echo "Copying repository contents..."
cp -r $DEPLOYMENT_SOURCE/* $DEPLOYMENT_TARGET/

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Install pip if not available
if ! command -v pip &> /dev/null; then
    echo "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    /usr/bin/python3 get-pip.py --user
    export PATH="/home/.local/bin:$PATH"
    rm get-pip.py
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --user -r requirements.txt

# Set up Django environment
export DJANGO_SETTINGS_MODULE=core.settings.production
export PYTHONPATH=$DEPLOYMENT_TARGET

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

echo "Deployment completed successfully!"
