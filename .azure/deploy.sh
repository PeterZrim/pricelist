#!/bin/bash

# If this is initial deployment, install system dependencies
if [ ! -d "$DEPLOYMENT_TARGET/antenv" ]; then
    echo "Installing system dependencies..."
    apt-get update
    apt-get install -y python3-venv python3-dev
fi

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Create and activate virtual environment if it doesn't exist
if [ ! -d "antenv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv antenv
fi

# Activate virtual environment
source antenv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

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
    <httpPlatform processPath="/usr/bin/python3"
                  arguments="$DEPLOYMENT_TARGET/antenv/bin/gunicorn core.wsgi:application --bind=0.0.0.0:8000 --workers=2 --threads=4 --worker-class=gthread --timeout=600"
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

echo "Deployment completed successfully!"
