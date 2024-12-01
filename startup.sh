#!/bin/bash

# Activate virtual environment
source /home/site/wwwroot/env/bin/activate

# Set environment variables
export PYTHONPATH=/home/site/wwwroot
export DJANGO_SETTINGS_MODULE=core.settings.production
export PORT="${PORT:-8000}"

# Start Gunicorn
exec gunicorn core.wsgi:application \
    --bind=0.0.0.0:$PORT \
    --workers=2 \
    --threads=4 \
    --worker-class=gthread \
    --timeout=600 \
    --access-logfile=- \
    --error-logfile=- \
    --capture-output \
    --enable-stdio-inheritance
