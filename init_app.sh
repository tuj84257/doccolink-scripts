#!/bin/bash

REPOSITORY_PATH=DoccoLink-Development-Repo
DOCKER_COMPOSE_PATH=DoccoLink-Development-Repo/docker-compose.yml

echo ""
echo "---STARTING DOCCOLINK INITIALIZATION---"

# -- PULL REPOSITORY FROM GITHUB -- #

echo ""
echo "Pulling the master branch from the GitHub repository..."
git clone https://github.com/tuj84257/DoccoLink-Development-Repo
echo "Finished downloading the repository"

# -- EDIT web_variables.env -- #

echo ""
echo "Updating the environment variables..."
sed -i "1s/$/doccolink@gmail.com/" ${REPOSITORY_PATH}/web_variables.env  # append email address to the first line of web_variables.env
read -p "- Enter the password for doccolink@gmail.com: " email_password
# echo ""
sed -i "2s/$/$email_password/" ${REPOSITORY_PATH}/web_variables.env    # append email password
read -p "- Enter the superuser username: " superuser_username
sed -i "3s/$/$superuser_username/" ${REPOSITORY_PATH}/web_variables.env # append superuser username
read -p "- Enter the superuser password: " superuser_password
# echo ""
sed -i "5s/$/$superuser_password/" ${REPOSITORY_PATH}/web_variables.env # append superuser password
read -p "- Enter the superuser email: " superuser_email
sed -i "4s/$/$superuser_email/" ${REPOSITORY_PATH}/web_variables.env # append superuser email
echo "Finished updating the environment variables."

# -- BUILD AND RUN THE CONTAINERS -- #

echo ""
echo "Building the application containers..."
sudo docker-compose -f ${DOCKER_COMPOSE_PATH} build
echo "Finished building the application containers..."
echo "Bringing the application containers up..."
sudo docker-compose -f ${DOCKER_COMPOSE_PATH} up -d
echo "The application containers are up."

echo "---FINISHED DOCCOLINK INITIALIZATION---"
