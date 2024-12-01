#!/bin/bash

# Install system dependencies
apt-get update
apt-get install -y python3-venv python3-dev

# Change to the app directory
cd $HOME/site/wwwroot

# Create and activate virtual environment
python3 -m venv antenv
source antenv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Export environment variables
export DJANGO_SETTINGS_MODULE=core.settings.production
export PYTHONPATH=$HOME/site/wwwroot
export PORT=8000

# Collect static files
python manage.py collectstatic --noinput

# Apply database migrations
python manage.py migrate --noinput

# Start Gunicorn
exec gunicorn core.wsgi:application --bind=0.0.0.0:8000 --workers=2 --threads=4 --worker-class=gthread --timeout=600
