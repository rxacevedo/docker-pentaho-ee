#!/usr/bin/env sh

set -e

JAR_DIR=$1

echo "Installing ${JAR_DIR}...";

# Note, this only works with the current PENTAHO_VERSION numbering scheme: X.X.X.X-XXX
if [ 6 -le "${PENTAHO_VERSION%.*.*.*}" ]; then
  # For 6 and up
  exec >/dev/null 2>&1
  echo "-----INSTALLING FOR 6+-----"
  echo -e "q1\n${COMPONENTS_DIR}\n1\n" | java -Djava.awt.headless=true -jar ${JAR_DIR}/installer.jar
else
  exec >/dev/null 2>&1
  echo "-----INSTALLING FOR 5-----"
  java -jar "${JAR_DIR}/installer.jar" << EOF













1
${COMPONENTS_DIR}
1
EOF
fi
