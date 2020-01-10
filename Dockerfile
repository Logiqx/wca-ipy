# Base image versions
ARG NOTEBOOK_VERSION=c39518a3252f
ARG PYTHON_VERSION=3.8
ARG ALPINE_VERSION=3.10

# Jupyter notebook image is used as the builder
FROM jupyter/base-notebook:${NOTEBOOK_VERSION} AS builder

# Copy the required project files
WORKDIR /home/jovyan/work/wca-ipy
COPY --chown=jovyan:users python/*.*py* ./python/
COPY --chown=jovyan:users sql/*.sql ./sql/
COPY --chown=jovyan:users templates/*.html ./templates/

# Convert Jupyter notebooks to regular Python scripts
RUN jupyter nbconvert --to python python/*.ipynb && \
    rm python/*.ipynb

# Ensure project file permissions are correct
RUN chmod 755 python/*.py && \
    chmod 644 sql/*.sql && \
    chmod 644 templates/*.html

# Create final image from Python 3 + Beautiful Soup 4 on Alpine Linux
FROM logiqx/python-bs4:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

# Note: Jovian is a fictional native inhabitant of the planet Jupiter
ARG PY_USER=jovyan
ARG PY_GROUP=jovyan
ARG PY_UID=1000
ARG PY_GID=1000

# Create the Python user and work directory
RUN addgroup -g ${PY_GID} ${PY_GROUP} && \
    adduser -u ${PY_UID} --disabled-password ${PY_USER} -G ${PY_GROUP} && \
    mkdir -p /home/${PY_USER}/work && \
    chown -R ${PY_USER} /home/${PY_USER}

# Install Tini
RUN apk add --no-cache tini=~0.18

# Environment variables used by the Python scripts
ENV MYSQL_HOST=mariadb
ENV MYSQL_DATABASE=wca_ipy
ENV MYSQL_USER=wca_ipy

# Debugging is off by default
ARG LOGIQX_DEBUG=0
ENV LOGIQX_DEBUG=${LOGIQX_DEBUG}

# Install Python libraries
RUN pip install --no-cache-dir sqlparse==0.3.* PyMySQL==0.9.*

# Copy project files from the builder
USER ${PY_USER}
WORKDIR /home/${PY_USER}/work/wca-ipy
COPY --from=builder --chown=jovyan:jovyan /home/jovyan/work/wca-ipy/ ./
RUN mkdir data docs

# Wait for CMD to exit, reap zombies and perform signal forwarding
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["python"]
