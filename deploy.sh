#!/bin/bash

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Create and activate virtual environment
/opt/python/3.11/bin/python3 -m venv antenv
source antenv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Export environment variables
export DJANGO_SETTINGS_MODULE=core.settings.production
export PYTHONPATH=$DEPLOYMENT_TARGET

# Collect static files
python manage.py collectstatic --noinput

# Apply database migrations
python manage.py migrate --noinput

# Create web.config file for Azure
cat > web.config << EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="httpPlatformHandler" path="*" verb="*" modules="httpPlatformHandler" resourceType="Unspecified" />
    </handlers>
    <httpPlatform processPath="%HOME%\site\wwwroot\antenv\Scripts\python.exe"
                  arguments="%HOME%\site\wwwroot\antenv\Scripts\gunicorn.exe core.wsgi:application --bind=0.0.0.0:8000 --workers=2 --threads=4 --worker-class=gthread --timeout=600"
                  stdoutLogEnabled="true"
                  stdoutLogFile="%HOME%\LogFiles\python.log"
                  startupTimeLimit="60">
      <environmentVariables>
        <environmentVariable name="PYTHONPATH" value="%HOME%\site\wwwroot" />
        <environmentVariable name="DJANGO_SETTINGS_MODULE" value="core.settings.production" />
      </environmentVariables>
    </httpPlatform>
  </system.webServer>
</configuration>
EOF

# Make startup script executable
chmod +x startup.sh
