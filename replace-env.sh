#!/bin/bash

laravel_path=$1
mydir=$2
db_name=$3
laravel_version=8.5.22
internal_port=3000

if [ -n "$4" ]
then
	laravel_version=$4
	internal_port=8000
fi

sed -i "s~PROJECT_PATH=.*~PROJECT_PATH=$mydir~g" $laravel_path/.env
sed -i "s~DB_DATABASE=.*~DB_DATABASE=$db_name~g" $laravel_path/.env
sed -i "s~LARAVEL_VERSION=.*~LARAVEL_VERSION=$laravel_version~g" $laravel_path/.env
sed -i "s~LARAVEL_INTERNAL_PORT=.*~LARAVEL_INTERNAL_PORT=$internal_port~g" $laravel_path/.env
