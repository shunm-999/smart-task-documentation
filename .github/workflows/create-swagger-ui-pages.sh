#!/usr/bin/env bash

set -e

function tsp_compile() {
    pushd main/spec >/dev/null
    npm install
    tsp compile .
    popd >/dev/null
}

function extract_versions() {
    versions=""
    for file in main/spec/tsp-output/@typespec/openapi3/openapi.*.yaml; do
        version=$(echo $file | sed -E 's/.*openapi3\/openapi\.(.*)\.yaml/\1/')
        versions=$(echo -e "$versions\n$version")
    done
    echo $versions
}

function extract_highest_version() {
    if [[ ! $# -ge 1 ]]; then
        echo "Usage: $0 <versions>"
        exit 1
    fi
    versions=$1
    highest_version=$(echo $versions | sort | tail -n 1)
    echo $highest_version
}

function create_swagger_ui_page() {
    version=""
    target_dir=""
    if [[ $# -ge 2 ]]; then
        version=$1
        target_dir=main/docs/dist/swagger-ui/$2
    elif [[ $# -ge 1 ]]; then
        version=$1
        target_dir=main/docs/dist/swagger-ui
    else
        echo "Usage: $0 <version> <parent_dir>"
        exit 1
    fi

    mkdir -p $target_dir
    cp main/spec/tsp-output/@typespec/openapi3/openapi.$version.yaml $target_dir/swagger.yaml
    cp swagger-ui/dist/* $target_dir
    create_index_html $target_dir/index.html
}

function create_index_html() {
    html=$(
        cat <<EOF >$1
<!-- HTML for static distribution bundle build -->
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Swagger UI</title>
    <link rel="stylesheet" type="text/css" href="./swagger-ui.css" />
    <link rel="stylesheet" type="text/css" href="index.css" />
    <link rel="icon" type="image/png" href="./favicon-32x32.png" sizes="32x32" />
    <link rel="icon" type="image/png" href="./favicon-16x16.png" sizes="16x16" />
</head>

<body>
    <div id="swagger-ui"></div>
    <script src="./swagger-ui-bundle.js" charset="UTF-8"> </script>
    <script src="./swagger-ui-standalone-preset.js" charset="UTF-8"> </script>
    <script src="./swagger-initializer.js" charset="UTF-8"> </script>
    <script>
        window.onload = () => {
            window.ui = SwaggerUIBundle({
                url: new URL(location).searchParams.get('q') || 'swagger.yaml',
                deepLinking: true,
                dom_id: '#swagger-ui',
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIStandalonePreset
                ],
                layout: "StandaloneLayout",
            });
        };
    </script>
</body>

</html>
EOF
    )
}

tsp_compile

versions=$(extract_versions)
highest_version=$(extract_highest_version $versions)

for version in $versions; do
    create_swagger_ui_page $version $version
done

create_swagger_ui_page $highest_version
