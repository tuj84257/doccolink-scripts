#!/bin/bash

REPOSITORY_PATH=DoccoLink-Development-Repo
DOCKER_COMPOSE_PATH=DoccoLink-Development-Repo/docker-compose.yml
DATABASE_BACKUP_DIRECTORY_PATH=database_backups

echo ""
echo "---STARTING DOCCOLINK UPDATE---"
echo ""

# -- BACKUP THE DATABASE -- #

echo "Starting database backup..."

if [ -d "${DATABASE_BACKUP_DIRECTORY_PATH}" ]
then
        echo "Directory database_backups exists."
else
        echo "Directory database_backups does not exist!"
        mkdir ${DATABASE_BACKUP_DIRECTORY_PATH}
        echo "Created the database_backups directory."
fi

sudo docker exec -t db pg_dumpall -c -U postgres > database_backups/update_dump_$(date +%Y-%m-%d_%H_%M_%S).sql  # https://stackoverflow.com/questions/24718706/backup-restore-a-dockerized-postgresql-database/63435830#63435830
echo "Finished database backup."

# -- TAKE DOWN THE APPLICATION CONTAINERS -- #

echo ""
echo "Taking down the application containers..."
sudo docker-compose -f ${DOCKER_COMPOSE_PATH} down
echo "Finished taking down the application containers"

# -- CLEAN UP THE DOCKER SYSTEM -- #

sudo docker system prune -a -f			# clear all images	(this is to make sure that there's enough memory allocated for Docker to build the app)
sudo docker system prune --volumes -f		# clear all volumes

# -- UPDATE THE REPOSITORY -- #

echo ""
echo "Starting repository update..."

if [ -d "${REPOSITORY_PATH}" ]
then
        rm -rf ${REPOSITORY_PATH}
        echo "Removed the old repository."
fi

echo "Pulling the updated master branch from the GitHub repository..."
git clone https://github.com/tuj84257/DoccoLink-Development-Repo
echo "Finished updating the repository"

# -- EDIT web_variables.env -- #

echo ""
echo "Updating the environment variables..."
sed -i "1s/$/doccolink@gmail.com/" ${REPOSITORY_PATH}/web_variables.env  # append email address to the first line of web_variables.env
read -sp "- Enter the password for doccolink@gmail.com: " email_password
echo ""
sed -i "2s/$/$email_password/" ${REPOSITORY_PATH}/web_variables.env    # append email password
read -p "- Enter the superuser username: " superuser_username
sed -i "3s/$/$superuser_username/" ${REPOSITORY_PATH}/web_variables.env # append superuser username
read -sp "- Enter the superuser password: " superuser_password
echo ""
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

# -- RESTORE THE DATABASE -- #

echo ""
echo "Restoring the database..."
most_recent_database_backup=$(ls -td ${DATABASE_BACKUP_DIRECTORY_PATH}/update_dump*| head -1)
string=${most_recent_database_backup//\// }                 # replace / with space   https://stackoverflow.com/a/5257398/13659134
database_backup_file=${string##* }	# get last substring
echo "Found database backup file to restore: ${database_backup_file}"
cat ${DATABASE_BACKUP_DIRECTORY_PATH}/${database_backup_file} | sudo docker exec -i db psql -U postgres -d postgres

echo "Finished restoring the database."
echo ""
echo "---FINISHED DOCCOLINK UPDATE---"
