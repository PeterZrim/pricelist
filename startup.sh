#!/bin/bash

# Make migrations
python manage.py makemigrations
python manage.py migrate

# Start Gunicorn
gunicorn --bind=0.0.0.0:8000 core.wsgi:application
