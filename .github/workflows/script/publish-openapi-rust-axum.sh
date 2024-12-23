#!/usr/bin/env bash

set -e

function cargo_publish() {
    pushd main/openapi-generator/build/rust-axum >/dev/null
    cargo publish
    popd >/dev/null
}

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

bash tsp_compile.sh

bash openapi-generator-cli.sh generate \
    -i main/spec/tsp-output/@typespec/openapi3/openapi."$version".yaml \
    -g rust-axum \
    -o main/openapi-generator/build/rust-axum \
    --additional-properties packageName=smart_task_openapi_axum,packageVersion="$version"

# Add License to Cargo.toml
# license = "MIT/Apache-2.0"

cargo_toml_path="main/openapi-generator/build/rust-axum/Cargo.toml"

line_number=$(grep -n edition <"$cargo_toml_path" | awk '{print $1}' FS=:)
pre_license=$(head -n "$line_number" <"$cargo_toml_path")
line_number=$((line_number + 1))
post_license=$(tail -n +"$line_number" <"$cargo_toml_path")

echo "$pre_license" >"$cargo_toml_path"
echo "license = \"MIT/Apache-2.0\"" >>"$cargo_toml_path"
echo "$post_license" >>"$cargo_toml_path"

# Publish Cargo crates
cargo_publish
