# Laravel Docker
This repo contains scripts that will help you organize your development environment using docker without the need to install neither PHP, laravel or composer on your machine.

# Requirements
- docker
- docker-compose
- linux host machine

# Preparation

After cloning this repo, rename the `env.sample` to `.env`

Add the following to you `~/.bashrc` file:
```
alias laravel="<PATH_TO_THIS_REPO>/laravel.sh"
```
**NB: for this alias to take effect, you either need to start a new terminal session or use the following command in the same terminal:**
```
source ~/.bashrc
```

Then, make your scripts executable by using this command:
```
chmod +x ./*.sh
```

Finally, make sure to change the value of the variable `laravel_path` in `laravel.sh` to the path where this repo is cloned.  
Also, you can change the value of each variable in the `.env` file.  
**NB: The `PROJECT_PATH` variable value will change dynamically depending on where you use the `laravel` alias command**

This project uses the `bitnami/laravel` official docker image. If you wish to change the `LARAVEL_VERSION` variable, make sure to check the existence of that container on their [docker hub repo](https://hub.docker.com/r/bitnami/laravel)

# Usage

These scripts can be used either to create a new laravel project or to use an existing one.

Make sure you are in the directory where the project is or will be.
## Create new project
Use the following command to create a new laravel project:
```
laravel new <DB_NAME>
```

The above command will first start a mysql container, create the database and a user and grant the user full privileges on that database.
It will then start the laravel cluster (laravel server, mysql database, phpmyadmin server, mailhog smtp server) and start creating the laravel files, then when done, migrate the database and start the server on `localhost` port 80 (you can change the port from the `.env` file). phpmyadmin is running on port 8080.

The database and laravel files will be stored on the host machine in the current directory under `mysql` and `website` directories respectively.

## Run existing project
Use the following command to run an existing project:
```
laravel server start <DB_NAME>
```

The reason we pass `<DB_NAME>` as a parameter is to allow multiple projects to exist on the same machine (in different directories of course).  
UPDATE: now you do not need to pass the `<DB_NAME>` parameter as it will read it from the `.env` file from inside the project

**NB: The server will take a little time to be ready after the container has started.**  
You can follow the laravel server logs using the following command:
```
docker logs -f laravel_app
```

## Run cloned project (first time)
We can use the same command to create a new project:
```
laravel new <DB_NAME>
```

This will create a database, user and grant them privileges. It will then install all project dependencies before starting the laravel server.

## Run tinker
Using this command while laravel server is running:
```
laravel tinker
```

## Install new composer package
Using this command while laravel server is running:
```
laravel composer <PACKAGE_NAME>
```

This will install the composer package in the project

## Start new fresh database
Using this command while laravel server is running:
```
laravel migrate [--seed]
```

The `--seed` parameter is optional

## Run any artisan command
Using this command while laravel server is running:
```
# similar to the command:
php artisan make:controller ProductController

# use it as follows, simply replace "php" with "laravel"
laravel artisan <COMMAND> <ARGUMENTS>

```

## Stop the server
Using this command while laravel server is running:
```
laravel server stop
```