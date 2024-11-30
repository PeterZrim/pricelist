#!/bin/bash

# Collect static files
python manage.py collectstatic --noinput

# Make migrations
python manage.py makemigrations
python manage.py migrate

# Start Gunicorn with base settings
DJANGO_SETTINGS_MODULE=core.settings.base gunicorn --bind=0.0.0.0:8000 core.wsgi:application
