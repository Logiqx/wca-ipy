# Docker

## Background

This project uses [Docker](https://www.docker.com/) to spin up the [MariaDB](https://mariadb.org/) and [Jupyter Notebook](https://jupyter.org/) services. The use of Docker allows environments to be created and destroyed easily on different machines without any version, configuration, depedency or compatibility issues.




## Docker Compose

The use of [Docker Compose](https://docs.docker.com/compose/) means that the Docker containers can be quickly created / destroyed and started / paused / stopped from the command line.

The MariaDB and Jupyter Notebook services are defined with docker-compose.yml and the associated .env file. Docker Compose files are generally self-documenting but this one will be documented for the sake of clarity.

To create the required Docker images, volumes, networks and containers and start the services:

```
$ docker-compose up -d
```

To list the containers for the services:

```
$ docker-compose ps
     Name                  Command              State           Ports
------------------------------------------------------------------------------
wca_mariadb_1    docker-entrypoint.sh mysqld    Up      0.0.0.0:3306->3306/tcp
wca_notebook_1   tini -g -- start-notebook.sh   Up      0.0.0.0:8888->8888/tcp
```

To stop the services and destroy the containers:

```
$ docker-compose down
```

Other useful commands include "start", "pause" and "stop"



## Docker Swarm

As an alternative to Docker Compose the services can be deployed with Docker Swarm.

To initialise the swarm:

```
$ docker swarm init
Swarm initialized: current node (nkgp43na417b4o9ybqyny6btw) is now a manager.
```

Since Docker Swarm does not support .env files, Docker Compose is required as a pre-processor:

```
$ docker-compose config | docker stack deploy -c - wca
                       or
$ docker stack deploy -c <(docker-compose config) wca
```

To list the services / tasks in the stack:

```
$ docker stack services wca
...
$ docker stack ps wca
...
```

To remove the stack:

```
$ docker stack rm wca
```



## Docker Services

### MariaDB

[MariaDB](https://mariadb.org/) is being used as an alternative to [MySQL](https://www.mysql.com/) because it generally performs better for this project.

The Docker service is defined in docker-compose.yml.

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

```ini
# Desired version of MariaDB (Official Docker image)
MARIADB_VERSION=10.3
```

#### Environment Variables

##### MYSQL_DATABASE

The database  is created automatically on start-up and the name is specified in .env file.

```ini
# Database to create on startup
MYSQL_DATABASE=wca
```

##### MYSQL_RANDOM_ROOT_PASSWORD

The root user is assigned a random password on start-up and can be found in the Docker logs.

```
$ docker logs wca_mariadb_1 2>&1 | grep -i generated
GENERATED ROOT PASSWORD: ahM2dei1EDaid8ah5TeRai6laiQu6eeK
```

##### MYSQL_USER

The WCA user is created automatically on start-up and the name is specified in .env file.

```ini
# User to create on startup
MYSQL_USER=wca
```

The default password is specified in mysql_password.txt and is supplied to the container as a "secret".

```ini
change.me
```

#### Secrets

[Docker Secrets](https://docs.docker.com/engine/swarm/secrets/) are used to provide the initial password for the WCA user mentioned earlier.

It may be overkill in this instance but secrets are more appropriate for passwords than standard environment variables.

#### Ports

The default port 3306 is being exposed to the host machine for tools such as [MySQL Workbench](https://www.mysql.com/products/workbench/).

#### Volumes

##### Project Root

A [bind mount](https://docs.docker.com/storage/bind-mounts/) at PROJECT_ROOT allows directories to be shared between MariaDB and Jupyter Notebooks.

```ini
# Location of the bind mount for /home/jovyan/work
PROJECT_ROOT=../..
```

Note: PROJECT_ROOT is defined as ../.. so that a number of related projects can be accessed.

##### MariaDB Configuration

A bind mount is used for wca.cnf which is the MariaDB server configuration, primarily performance related.

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

```
$ docker volume ls
DRIVER              VOLUME NAME
local               wca_mariadb
```



### Jupter Notebook

[Jupter Notebooks](https://jupyter.org/) are popular amongst Data Scientists as a Python IDE and presentation tool.

The Docker service is defined in docker-compose.yml.

```yaml
notebook:
  build:
    context: ./notebook
    args:
      NOTEBOOK_VERSION: ${NOTEBOOK_VERSION}
  image: ${COMPOSE_PROJECT_NAME:-wca}_notebook:${PROJECT_NOTEBOOK_VERSION:-latest}-${NOTEBOOK_VERSION:-latest}
  environment:
    MYSQL_HOSTNAME: mariadb
    MYSQL_DATABASE: ${MYSQL_DATABASE}
    MYSQL_USER: ${MYSQL_USER}
  ports:
    - "8888:8888"
  volumes:
    - ${PROJECT_ROOT}:/home/jovyan/work
    - ./mysql/.my.cnf:/home/jovyan/.my.cnf
  depends_on:
    - mariadb
```

#### Image Build

A custom notebook image is built from notebook/Dockerfile and is a derivative of the image on [Docker Hub](https://hub.docker.com/r/jupyter/base-notebook/). The [base notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#core-stacks) is used for this project because the larger development stacks are not required.
```dockerfile
ARG NOTEBOOK_VERSION
FROM jupyter/base-notebook:${NOTEBOOK_VERSION:-latest}

RUN pip install beautifulsoup4 lxml

USER root
RUN apt-get update && apt-get install -y --no-install-recommends mysql-client
USER jovyan
```

The custom notebook image includes the following additional components:

1) The Python Library [Beautiful Soup](https://www.crummy.com/software/BeautifulSoup/) is used for parsing HTML.
2) The MySQL [Command-Line Client](https://dev.mysql.com/doc/refman/5.7/en/mysql.html) is used to execute SQL scripts.

#### Image Tag

The custom image is tagged using a combination of the following variables from the .env file.

```ini
# Desired version of Jupyter Notebook
NOTEBOOK_VERSION=c39518a3252f

# Tag for the custom notebook image
PROJECT_NOTEBOOK_VERSION=1.0
```

The custom image can be identified from the command line.

```
$ docker image ls wca_notebook
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
wca_notebook        1.0-c39518a3252f    0422cfc20927        About an hour ago   909MB
```

#### Access Token

A random access token is generated on start-up and can be found in the Docker logs.

```
$ docker logs wca_notebook_1 2>&1 | grep token
http://(14f9a3503875 or 127.0.0.1):8888/?token=d7d8bf386490342fd934486e681b20643c1b148e1c86795c
```

#### Environment Variables

##### MYSQL_HOSTNAME

The database hostname should match the MariaDB service name in docker-compose.yml.

```ini
MYSQL_HOSTNAME=mariadb
```

##### MYSQL_DATABASE

The database name is shared with the MariaDB service and is specified in the .env file.

```ini
MYSQL_DATABASE=wca
```

##### MYSQL_USER

The WCA user name is shared with the MariaDB service and is specified in the .env file.

```ini
MYSQL_USER=wca
```

#### Ports

The default port 8888 is being exposed to the host machine for web browser access.

#### Volumes

##### Project Root

A [bind mount](https://docs.docker.com/storage/bind-mounts/) at PROJECT_ROOT allows directories to be shared between Jupyter Notebooks and MariaDB.

```ini
# Location of the bind mount for /home/jovyan/work
PROJECT_ROOT=../..
```

Note: PROJECT_ROOT is defined as ../.. so that a number of related projects can be accessed.

##### MySQL Configuration

A bind mount is used for .my.cnf which is the MariaDB client configuration, primarily the user password.

```ini
[client]
password=change.me
```

#### Dependencies

The Jupyter notebooks run SQL against the MariaDB database so a service dependency has been declared.

This isn't entirely necessary but it does provide some documentation benefits.



## Docker for Windows

### Bind Mounts

This project uses bind mounts which can initially be a little tricky to get working on Windows.

The section below provides some basic pointers as to what is required in the way of setup.

#### Setup

##### Docker For Windows

Settings -> Shared Drives -> C

##### Share C: Drive

Right-click C: -> Properties -> Sharing -> Share...

##### Anti-Virus Exclusion

Norton -> Settings -> Firewall -> Configure Public Network Exceptions -> File and Printer Sharing

