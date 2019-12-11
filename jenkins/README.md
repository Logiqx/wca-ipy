# Jenkins

Jenkins is used by this project for CI/CD and scheduled batch jobs.

Rather than describe all of the jobs in great detail this document will simply list the dependencies.



## wca-ipy-refresh-rankings

This job generates all of the senior rankings and has the following dependencies:

- wca-ipy-refresh-rankings
  - wca-ipy-fomat-extracts
    - wca-db-download-results
      - *Schedule 10 4 \* \* \**
      - wca-db-docker-build
        - *GitHub trigger on wca-db repository*
    - wca-ipy-private-load-data
      - wca-ipy-private-docker-build
        - *GitHub trigger on wca-ipy-private repository*
    - wca-ipy-docker-build
      - *GitHub trigger on wca-ipy repository*

To set up Jenkins the jobs should be created and run in the following order:

1. wca-db-docker-build
2. wca-db-download-results
3. wca-ipy-private-docker-build
4. wca-ipy-private-load-data
5. wca-ipy-docker-build
6. wca-ipy-fomat-extracts
7. wca-ipy-refresh-rankings



## wca-ipy-refresh-competitions

This job generates the list of future competitions  and has the following dependencies:

- wca-ipy-refresh-competitions
  - *Schedule 0 \*/3 \* \* \**
  - wca-ipy-docker-build
    - *GitHub trigger on wca-ipy repository*

This job should only be created and run after wca-ipy-fomat-extracts.

