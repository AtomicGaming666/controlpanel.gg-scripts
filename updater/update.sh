#!/bin/bash

# Set colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running update script...${NC}"

# Enable Maintenance Mode
echo -e "${YELLOW}Enabling maintenance mode...${NC}"
cd /var/www/controlpanel
sudo php artisan down

# Pulling the New Files
echo -e "${YELLOW}Pulling the new files...${NC}"
sudo git stash
sudo git pull
sudo chmod -R 755 /var/www/controlpanel

# Update Dependencies
echo -e "${YELLOW}Updating dependencies...${NC}"
sudo composer install --no-dev --optimize-autoloader

# Updating the Database
echo -e "${YELLOW}Updating the database...${NC}"
sudo php artisan migrate --seed --force

# Clear Compiled Template Cache
echo -e "${YELLOW}Clearing compiled template cache...${NC}"
sudo php artisan view:clear
sudo php artisan config:clear

# Set Permissions
echo "Which operating system are you using?"
echo "1. CentOS"
echo "2. Other"
read os

if [ $os -eq 1 ]; then
  echo "Which web server are you using?"
  echo "1. NGINX"
  echo "2. Apache"
  read server

  if [ $server -eq 1 ]; then
    echo -e "${YELLOW}Setting permissions for NGINX on CentOS...${NC}"
    sudo chown -R nginx:nginx /var/www/controlpanel/
  elif [ $server -eq 2 ]; then
    echo -e "${YELLOW}Setting permissions for Apache on CentOS...${NC}"
    sudo chown -R apache:apache /var/www/controlpanel/
  else
    echo "Invalid selection"
  fi
elif [ $os -eq 2 ]; then
  echo -e "${YELLOW}Setting permissions for NGINX or Apache (not on CentOS)...${NC}"
  sudo chown -R www-data:www-data /var/www/controlpanel/
else
  echo "Invalid selection"
fi

# Restarting Queue Workers
echo -e "${YELLOW}Restarting queue workers...${NC}"
sudo php artisan queue:restart

# Disable Maintenance Mode
echo -e "${YELLOW}Disabling maintenance mode...${NC}"
sudo php artisan up

echo -e "${GREEN}Update complete. Thank you for using the script!${NC}"
