"""
Development settings for the Pricelist project.
"""
from .base import *

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = ['localhost', '127.0.0.1']

# SECURITY WARNING: define the correct hosts in production!
CSRF_TRUSTED_ORIGINS = ['http://localhost:8000', 'http://127.0.0.1:8000']

# Email backend for development
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
