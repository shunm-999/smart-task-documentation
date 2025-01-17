#!/usr/bin/env bash

# Generate ReDoc documentation
version="1.0.0"

if [[ $# -ge 2 ]]; then
    case "$1" in
    -v | --version)
        version="$2"
        shift 2
        ;;
    *)
        echo "Usage: $0 [-v|--version <version>]"
        exit 1
        ;;
    esac
fi

tsp compile .

echo "You can view documentation in http://localhost:8080"

docker run -it --rm -p 8080:80 \
    -v $(pwd)/tsp-output/@typespec/openapi3/openapi.${version}.yaml:/usr/share/nginx/html/openapi.yaml \
    -e SPEC_URL=openapi.yaml redocly/redoc
