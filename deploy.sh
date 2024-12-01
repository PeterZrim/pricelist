#!/bin/bash

# Navigate to project directory
cd "$DEPLOYMENT_TARGET" || exit 1

# Create web.config file for Azure
cat > web.config << EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="httpPlatformHandler" path="*" verb="*" modules="httpPlatformHandler" resourceType="Unspecified" />
    </handlers>
    <httpPlatform processPath="bash"
                  arguments="startup.sh"
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
