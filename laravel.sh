#!/bin/bash

# available commands:
# server start $db_name
# server stop
# tinker
# migrate [[--seed]]
# composer $package_name
# new $db_name

laravel_path=/home/do/laravel
laravel_command="docker-compose -f $laravel_path/docker-compose.yml exec myapp"

if [ -z "$1" ]
then
	echo "Please specify the laravel command in the first argument"
else
	case $1 in
		"server")
			if [ -z "$2" ];then
				echo "Please specify 'start' or 'stop' in the second argument"
			else
				case $2 in
					"start")
						if [ -z "$3" ] && [ ! -f $(pwd)/website/.env ];then
							echo "Please specify the database name in the third argument"
						else
							db_name=""
							mydir=$(pwd)
							if [ -z "$3" ];then
								. $mydir/website/.env
								db_name=$DB_DATABASE
							else
								db_name=$3
							fi
							$laravel_path/replace-env.sh $laravel_path $mydir $db_name $4
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
			if [ ! "$(docker ps -q -f name=laravel_app)" ];then
				echo "laravel container is not running"
			else
				$laravel_command php artisan "${@:2}"
			fi
			;;
		"tinker")
			if [ ! "$(docker ps -q -f name=laravel_app)" ];then
				echo "laravel container is not running"
			else
				$laravel_command php artisan tinker
			fi
			;;
		"migrate")
			if [ ! "$(docker ps -q -f name=laravel_app)" ];then
				echo "laravel container is not running"
			else
				$laravel_command php artisan migrate:fresh $2
			fi
			;;
		"auth")
			$laravel_command composer require laravel/ui
			$laravel_command php artisan ui bootstrap --auth
			$laravel_command npm install

			# this is included twice since the first time it will throw an error and install dependencies, it will work the second time
			$laravel_command npm run build
			#$laravel_command npm run dev	
			;;
		"composer")
			if [ -z "$2" ];then
				echo "please specify which composer package you want to install in the second argument"
			else
				if [ ! "$(docker ps -q -f name=laravel_app)" ];then
					echo "laravel container is not running"
				else
					$laravel_command composer require $2
				fi
			fi
			;;
		"npm")
			if [ -z "$2" ];then
				echo "please specify which npm command to run"
			else
				$laravel_command npm "${@:2}"
			fi
			;;
		"new")
			if [ -z "$2" ];then
				echo "Please specify the database name in the second argument"
			else
				db_name=$2
				mydir=$(pwd)

				echo "creating project"
				mkdir $mydir/mysql
				mkdir $mydir/website # if we dont create this using our user, docker will create it from root and it will prevent us from proceeding due to lack of privileges
				$laravel_path/replace-env.sh $laravel_path $mydir $db_name $4
				docker-compose -f $laravel_path/docker-compose.yml --env-file $laravel_path/.env up -d

				echo "creating laravel file system..."
				docker logs -f laravel_app
			fi
			;;
		"help")
			echo "Available commands:"
			echo "laravel server start <DB_NAME> [<LARAVEL_VERSION>]"
			echo "laravel server stop"
			echo "laravel artisan <COMMAND>"
			echo "laravel tinker"
			echo "laravel migrate [--seed]"
			echo "laravel auth"
			echo "laravel composer <PACKAGE_NAME>"
			echo "laravel npm <COMMAND>"
			echo "laravel new <DB_NAME>"
			;;
		"test")
			mydir=$(pwd)
			echo "you are in dir: $mydir"
			echo "laravel path: $laravel_path"
			;;
		*) #default
			echo "$1 command invalid"
	esac
fi
