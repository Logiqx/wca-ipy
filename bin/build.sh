docker build . -t wca-ipy:$(git rev-parse --short=12 HEAD)
docker tag wca-ipy:$(git rev-parse --short=12 HEAD) wca-ipy:latest
