#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

# Check if Git is initialized
if [ ! -d .git ]; then
    echo -e "${GREEN}Initializing Git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit"
fi

# Add Azure remote if it doesn't exist
if ! git remote | grep -q "azure"; then
    echo -e "${GREEN}Please enter the Azure Git deployment URL:${NC}"
    read AZURE_GIT_URL
    git remote add azure $AZURE_GIT_URL
fi

# Deploy to Azure
echo -e "${GREEN}Deploying to Azure...${NC}"
git add .
git commit -m "Deploy to Azure"
git push azure master --force

echo -e "${GREEN}Deployment complete!${NC}"
echo "Your app should be available in a few minutes at your Azure Web App URL"
