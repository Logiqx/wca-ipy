# Base image versions
ARG NOTEBOOK_VERSION=c39518a3252f
ARG PYTHON_VERSION=3.7
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

# Create final image from Python (Alpine) + MySQL client
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION}
RUN apk update && \
    apk add mysql-client

# Environment variables
ENV NB_USER=jovyan
ENV PROJDIR=/home/${NB_USER}/work/wca-ipy

# Create the notebook user and project structure
RUN addgroup -S ${NB_USER} && adduser -S ${NB_USER} -G ${NB_USER}
USER ${NB_USER}

# Copy project files
COPY --from=builder --chown=jovyan:jovyan ${PROJDIR}/ ${PROJDIR}/

# Define the command / entrypoint
CMD ["python"]
