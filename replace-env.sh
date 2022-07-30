#!/bin/bash

laravel_path=$1
mydir=$2
db_name=$3

sed -i "s~PROJECT_PATH=.*~PROJECT_PATH=$mydir~g" $laravel_path/.env
sed -i "s~DB_DATABASE=.*~DB_DATABASE=$db_name~g" $laravel_path/.env
