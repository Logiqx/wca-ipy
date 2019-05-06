ARG NOTEBOOK_VERSION
FROM jupyter/base-notebook:${NOTEBOOK_VERSION:-latest}

RUN pip install beautifulsoup4 lxml

# Ideally apt-get would use sudo but it requires the jovyan password
USER root
RUN apt-get update && apt-get install -y --no-install-recommends mysql-client
USER jovyan
