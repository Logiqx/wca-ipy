# Base image versions
ARG NOTEBOOK_VERSION=c39518a3252f
ARG PYTHON_VERSION=3.8
ARG ALPINE_VERSION=3.10

# Jupter notebook image is used as the builder
FROM jupyter/base-notebook:${NOTEBOOK_VERSION} AS builder

# Environment variables
ENV NB_USER=jovyan
ENV PROJDIR=/home/${NB_USER}/work/wca-ipy

# Convert Jupter notebooks to regular Python scripts
COPY --chown=jovyan:users python/*.py ${PROJDIR}/python/
COPY --chown=jovyan:users python/*.ipynb ${PROJDIR}/python/
RUN jupyter nbconvert --to python ${PROJDIR}/python/*.ipynb && \
    chmod 755 ${PROJDIR}/python/*.py && \
    rm ${PROJDIR}/python/*.ipynb

# Copy the required SQL scripts
COPY --chown=jovyan:users sql/*.sql ${PROJDIR}/sql/
RUN chmod 644 ${PROJDIR}/sql/*.sql

# Copy the required document templates
COPY --chown=jovyan:users templates/*.md ${PROJDIR}/templates/
RUN chmod 644 ${PROJDIR}/templates/*.md

# Create final image from Python 3 + Beautiful Soup 4 on Alpine Linux
FROM logiqx/python-bs4:${PYTHON_VERSION}-alpine${ALPINE_VERSION}

# Install MySQL client
RUN apk add --no-cache mysql-client

# Environment variables
ENV NB_USER=jovyan
ENV PROJDIR=/home/${NB_USER}/work/wca-ipy

# Create the notebook user and project structure
RUN addgroup -g 1000 -S ${NB_USER} && \
    adduser -u 1000 -S ${NB_USER} -G ${NB_USER}
USER ${NB_USER}

# Copy project files
COPY --from=builder --chown=jovyan:jovyan ${PROJDIR}/ ${PROJDIR}/

# Create data and docs volumes
RUN cd ${PROJDIR} && \
    mkdir -p data/private/extract data/public docs && \
    cd data/public && \
    mkdir known_senior_averages known_senior_singles senior_singles senior_averages senior_averages_agg wca_averages_agg wca_singles_agg

# Define the command / entrypoint
CMD ["python3"]
