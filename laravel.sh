#!/bin/bash

# available commands:
# server start $db_name
# server stop
# tinker
# migrate [[--seed]]
# composer $package_name
# new $db_name

laravel_path=/home/do/laravel

if [ -z "$1" ]
then
	echo "Please specify the laravel command in the first argument"
else
	case $1 in
		"server")
			if [ -z "$2" ]
			then
				echo "Please specify 'start' or 'stop' in the second argument"
			else
				case $2 in
					"start")
						if [ -z "$3" ] && [ ! -f $(pwd)/website/.env ]
						then
							echo "Please specify the database name in the third argument"
						else
							db_name=""
							mydir=$(pwd)
							if [ -z "$3" ]
							then
								. $mydir/website/.env
								db_name=$DB_DATABASE
							else
								db_name=$3
							fi
							$laravel_path/replace-env.sh $laravel_path $mydir $db_name
							docker-compose -f $laravel_path/docker-compose.yml --env-file $laravel_path/.env up -d
						fi
						;;
					"stop")
						docker-compose -f $laravel_path/docker-compose.yml down
						;;
				esac
			fi
			;;
		"artisan")
			if [ ! "$(docker ps -q -f name=laravel_app)" ]
			then
				echo "laravel container is not running"
			else
				docker-compose -f $laravel_path/docker-compose.yml exec myapp php artisan "${@:2}"
			fi
			;;
		"tinker")
			if [ ! "$(docker ps -q -f name=laravel_app)" ]
			then
				echo "laravel container is not running"
			else
				docker-compose -f $laravel_path/docker-compose.yml exec myapp php artisan tinker
			fi
			;;
		"migrate")
			if [ ! "$(docker ps -q -f name=laravel_app)" ]
			then
				echo "laravel container is not running"
			else
				docker-compose -f $laravel_path/docker-compose.yml exec myapp php artisan migrate:fresh $2
			fi
			;;
		"composer")
			if [ -z "$2" ]
			then
				echo "please specify which composer package you want to install in the second argument"
			else
				if [ ! "$(docker ps -q -f name=laravel_app)" ]
				then
					echo "laravel container is not running"
				else
					docker-compose -f $laravel_path/docker-compose.yml exec myapp composer require $2
				fi
			fi
			;;
		"new")
			if [ -z "$2" ]
			then
				echo "Please specify the database name in the second argument"
			else
				db_name=$2
				mydir=$(pwd)
				$laravel_path/create-new.sh $laravel_path $mydir $db_name
			fi
			;;
	esac
fi
