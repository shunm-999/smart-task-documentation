#!/usr/bin/env bash

set -e

function tsp_compile() {
    pushd main/spec >/dev/null
    npm install -g @typespec/compiler
    npm install
    tsp compile . --output-dir tsp-output
    popd >/dev/null
}

tsp_compile
