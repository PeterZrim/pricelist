#!/bin/bash

# Configuration variables
RESOURCE_GROUP="pricelist-rg"
LOCATION="westeurope"
APP_NAME="pricelist-app"
DB_SERVER_NAME="pricelist-db"
DB_NAME="pricelistdb"
DB_USERNAME="pricelistadmin"
STORAGE_ACCOUNT_NAME="priceliststorage$RANDOM"
CONTAINER_NAME="media"

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Creating Resource Group...${NC}"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Generate a secure password for PostgreSQL
DB_PASSWORD=$(openssl rand -base64 32)
echo "Generated DB Password: $DB_PASSWORD"

echo -e "${GREEN}Creating PostgreSQL Server...${NC}"
az postgres server create \
    --resource-group $RESOURCE_GROUP \
    --name $DB_SERVER_NAME \
    --location $LOCATION \
    --admin-user $DB_USERNAME \
    --admin-password "$DB_PASSWORD" \
    --sku-name B_Gen5_1 \
    --version 11

echo -e "${GREEN}Configuring PostgreSQL Firewall...${NC}"
az postgres server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server-name $DB_SERVER_NAME \
    --name AllowAllAzureIPs \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255

echo -e "${GREEN}Creating PostgreSQL Database...${NC}"
az postgres db create \
    --resource-group $RESOURCE_GROUP \
    --server-name $DB_SERVER_NAME \
    --name $DB_NAME

echo -e "${GREEN}Creating Storage Account...${NC}"
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --encryption-services blob

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' -o tsv)

echo -e "${GREEN}Creating Storage Container...${NC}"
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --account-key $STORAGE_KEY \
    --public-access blob

echo -e "${GREEN}Creating App Service Plan (B1)...${NC}"
az appservice plan create \
    --name "${APP_NAME}-plan" \
    --resource-group $RESOURCE_GROUP \
    --sku B1 \
    --is-linux

echo -e "${GREEN}Creating Web App...${NC}"
az webapp create \
    --resource-group $RESOURCE_GROUP \
    --plan "${APP_NAME}-plan" \
    --name $APP_NAME \
    --runtime "PYTHON|3.11"

# Generate Django secret key
DJANGO_SECRET_KEY=$(openssl rand -base64 32)

echo -e "${GREEN}Configuring Web App Settings...${NC}"
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --settings \
    DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY" \
    AZURE_POSTGRESQL_DATABASE=$DB_NAME \
    AZURE_POSTGRESQL_USER="$DB_USERNAME@$DB_SERVER_NAME" \
    AZURE_POSTGRESQL_PASSWORD="$DB_PASSWORD" \
    AZURE_POSTGRESQL_HOST="$DB_SERVER_NAME.postgres.database.azure.com" \
    AZURE_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME \
    AZURE_STORAGE_ACCOUNT_KEY="$STORAGE_KEY" \
    AZURE_STORAGE_CONTAINER_NAME=$CONTAINER_NAME \
    DJANGO_SETTINGS_MODULE="core.settings.production" \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    PYTHONPATH="/home/site/wwwroot" \
    WEBSITE_WEBDEPLOY_USE_SCM=true

# Enable logging
az webapp log config \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --docker-container-logging filesystem

echo -e "${GREEN}Configuring deployment source...${NC}"
az webapp deployment source config-local-git \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME

# Get the Git deployment URL
DEPLOY_URL=$(az webapp deployment list-publishing-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --query scmUri \
    --output tsv)

echo -e "\n${GREEN}=== Deployment Information ===${NC}"
echo "Web App URL: https://$APP_NAME.azurewebsites.net"
echo "Git deployment URL: $DEPLOY_URL"
echo "Database server: $DB_SERVER_NAME.postgres.database.azure.com"
echo "Database name: $DB_NAME"
echo "Database username: $DB_USERNAME@$DB_SERVER_NAME"
echo "Storage account name: $STORAGE_ACCOUNT_NAME"

# Save credentials to a secure file
echo -e "\n${GREEN}Saving credentials to .azure_credentials (keep this file secure!)${NC}"
cat > .azure_credentials << EOL
=== Azure Deployment Credentials ===
Web App URL: https://$APP_NAME.azurewebsites.net
Database Server: $DB_SERVER_NAME.postgres.database.azure.com
Database Name: $DB_NAME
Database Username: $DB_USERNAME@$DB_SERVER_NAME
Database Password: $DB_PASSWORD
Storage Account: $STORAGE_ACCOUNT_NAME
Storage Key: $STORAGE_KEY
Django Secret Key: $DJANGO_SECRET_KEY
Git Deployment URL: $DEPLOY_URL
EOL

chmod 600 .azure_credentials

echo -e "\n${GREEN}Setup complete! Credentials saved to .azure_credentials${NC}"
echo "IMPORTANT: Keep the .azure_credentials file secure and never commit it to version control!"
