#!/usr/bin/env bash

set -e

JAR_DIR=$1

echo "Installing ${JAR_DIR}...";
java -jar ${JAR_DIR}/installer.jar << EOF













1
${COMPONENTS_DIR}
1
EOF
