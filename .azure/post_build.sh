#!/bin/bash

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Activate the Python virtual environment
source /antenv/bin/activate

# Install additional dependencies
pip install gunicorn

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Create web.config file for Azure
echo "Creating web.config..."
cat > web.config << EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="httpPlatformHandler" path="*" verb="*" modules="httpPlatformHandler" resourceType="Unspecified" />
    </handlers>
    <httpPlatform processPath="/antenv/bin/python"
                  arguments="/antenv/bin/gunicorn core.wsgi:application --bind=0.0.0.0:8000 --workers=2 --threads=4 --worker-class=gthread --timeout=600"
                  stdoutLogEnabled="true"
                  stdoutLogFile="\$HOME\LogFiles\python.log"
                  startupTimeLimit="60">
      <environmentVariables>
        <environmentVariable name="PYTHONPATH" value="\$HOME\site\wwwroot" />
        <environmentVariable name="DJANGO_SETTINGS_MODULE" value="core.settings.production" />
      </environmentVariables>
    </httpPlatform>
  </system.webServer>
</configuration>
EOF

echo "Post-build steps completed successfully!"
