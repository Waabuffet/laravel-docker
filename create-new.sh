#!/bin/bash
laravel_path=$1
. $laravel_path/.env

mydir=$2
db_name=$3

docker run -d --rm --name mysql_server -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -v "$mydir/mysql:/var/lib/mysql" mysql

echo "waiting for mysql to be up"
while ! docker exec mysql_server mysql --user=root --password=$MYSQL_ROOT_PASSWORD -e "SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

echo "creating database"
docker exec mysql_server mysql --user=root --password=$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $db_name"

echo "creating user with privileges"
docker exec mysql_server mysql --user=root --password=$MYSQL_ROOT_PASSWORD -e "CREATE USER '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD'"
docker exec mysql_server mysql --user=root --password=$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$DB_USERNAME'@'%'"

docker stop mysql_server

echo "creating project"
mkdir $mydir/website # if we dont create this using our user, docker will create it from root and it will prevent us from proceeding due to lack of privileges
$laravel_path/replace-env.sh $laravel_path $mydir $db_name
docker-compose -f $laravel_path/docker-compose.yml --env-file $laravel_path/.env up -d

echo "creating laravel file system..."
docker logs -f laravel_app
