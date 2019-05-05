# Docker

## Background

This project uses [Docker](https://www.docker.com/) to spin up the [MariaDB](https://mariadb.org/) and [Jupyter Notebook](https://jupyter.org/) services. The use of Docker allows environments to be created and destroyed easily on different machines without any version, configuration, depedency or compatibility issues.




## Docker Compose

The use of [Docker Compose](https://docs.docker.com/compose/) means that the Docker containers can be quickly created / destroyed and started / paused / stopped from the command line.

The MariaDB and Jupyter Notebook services are defined with docker-compose.yml and the associated .env file. Docker Compose files are generally self-documenting but this one will be documented for the sake of clarity.

To create the required Docker images, volumes, networks and containers and start the services:

```sh
$ docker-compose up -d
```

To list the containers for the services:

```sh
$ docker-compose ps
     Name                  Command              State           Ports
------------------------------------------------------------------------------
wca_mariadb_1    docker-entrypoint.sh mysqld    Up      0.0.0.0:3306->3306/tcp
wca_notebook_1   tini -g -- start-notebook.sh   Up      0.0.0.0:8888->8888/tcp
```

To stop the services and destroy the containers:

```sh
$ docker-compose down
```

Other useful commands include "start", "pause" and "stop"



## MariaDB

 [MariaDB](https://mariadb.org/) is being used as an alternative to [MySQL](https://www.mysql.com/) because it generally performs better for this project.



### Docker Service

The Docker service is defined in docker-compose.yml:

```yaml
mariadb:
  image: mariadb:${MARIADB_VERSION:-latest}
  environment:
    MYSQL_DATABASE: ${MYSQL_DATABASE}
    MYSQL_RANDOM_ROOT_PASSWORD: "true"
    MYSQL_USER: ${MYSQL_USER}
    MYSQL_PASSWORD_FILE: /run/secrets/mysql_password
  secrets:
    - mysql_password
  ports:
    - "3306:3306"
  volumes:
    - ${PROJECT_ROOT}:/home/jovyan/work
    - ./mysql/wca.cnf:/etc/mysql/conf.d/wca.cnf
    - mariadb:/var/lib/mysql
secrets:
  mysql_password:
    file: ./mysql_password.txt
volumes:
  mariadbtest:
```



#### Image Tag

The official image from [Docker Hub](https://hub.docker.com/_/mariadb) is being used and the [release](https://downloads.mariadb.org/mariadb/+releases/) is specified in the .env file.

```sh
MARIADB_VERSION=10.3
```

#### Environment Variables

##### MYSQL_DATABASE

The database  is created automatically on start-up and the name is specified in .env file.

```sh
MYSQL_DATABASE=wca
```

##### MYSQL_RANDOM_ROOT_PASSWORD

The root user is assigned a random password on start-up and can be found in the Docker logs.

```sh
$ docker logs wca_mariadb_1 2>&1 | grep -i generated
GENERATED ROOT PASSWORD: ahM2dei1EDaid8ah5TeRai6laiQu6eeK
```

##### MYSQL_USER

The WCA user is created automatically on start-up and the name is specified in .env file.

```sh
MYSQL_USER=wca
```

The default password is specified in mysql_password.txt and is supplied to the container as a "secret".

```
change.me
```

#### Secrets

[Docker Secrets](https://docs.docker.com/engine/swarm/secrets/) are used to provide the initial password for the WCA user mentioned earlier.

It may be overkill in this instance but it secrets are more appropriate for passwords than standard environment variables.

#### Ports

The default port 3306 is being exposed to the host machine for tools such as [MySQL Workbench](https://www.mysql.com/products/workbench/).

#### Volumes

##### Work Folder

A [bind mount](https://docs.docker.com/storage/bind-mounts/) for $PROJECT_ROOT allows directories to be shared between MariaDB and Jupyter Notebook.

```sh
PROJECT_ROOT=../..
```

Note: $PROJECT_ROOT is defined as ../.. so that a number of similar / related projects can be accessed.

##### MariaDB Configuration

A bind mount is used for wca.cnf which is the MariaDB configuration, primarily performance related.

```ini
[mysqld]
innodb_buffer_pool_size        = 2G
innodb_log_file_size           = 512M
tmp_table_size                 = 512M
max_heap_table_size            = 512M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method            = O_DIRECT_NO_FSYNC
secure_file_priv               =
```

##### MariaDB Data

A named [volume](https://docs.docker.com/storage/volumes/) is used for the MariaDB data directory. This ensures that users and databases are persisted even when Docker containers are destroyed and re-created.

```sh
$ docker volume ls
DRIVER              VOLUME NAME
local               wca_mariadb
```



## Jupter Notebook

TODO