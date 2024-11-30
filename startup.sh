#!/bin/bash

# Change to the app directory
cd $HOME/site/wwwroot

# Create virtual environment if it doesn't exist
python -m venv antenv

# Activate virtual environment
source antenv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Export environment variables
export DJANGO_SETTINGS_MODULE=core.settings.base
export PYTHONPATH=$HOME/site/wwwroot

# Collect static files
python manage.py collectstatic --noinput

# Apply database migrations
python manage.py migrate

# Start Gunicorn
gunicorn core.wsgi:application --bind=0.0.0.0:8000
