#!/usr/bin/env bash

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

bash openapi-generator-cli.sh generate \
-i ../spec/tsp-output/@typespec/openapi3/openapi."$version".yaml \
-g rust-axum \
-o build/rust-axum \
--additional-properties packageName=smart_task_openapi_axum,packageVersion="$version"

# Add License to Cargo.toml
# license = "MIT/Apache-2.0"

line_number=$(grep -n edition < build/rust-axum/Cargo.toml | awk '{print $1}' FS=:)
pre_license=$(head -n "$line_number"  < build/rust-axum/Cargo.toml)
line_number=$((line_number + 1))
post_license=$(tail -n +"$line_number" < build/rust-axum/Cargo.toml)

echo "$pre_license" > build/rust-axum/Cargo.toml
echo "license = \"MIT/Apache-2.0\"" >> build/rust-axum/Cargo.toml
echo "$post_license" >> build/rust-axum/Cargo.toml