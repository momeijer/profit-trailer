#!/bin/bash

BASE=/opt
APP=/app
PT="ProfitTrailer"

PT_DIR=${APP}/${PT}
PT_ZIP=${BASE}/${PT}-${PT_VERSION}.zip
PT_JAR=${PT_DIR}/${PT}.jar

JAVA_OPTS="$JAVA_OPTS -XX:+IgnoreUnrecognizedVMOptions"           # Don't barf if we see an option we don't understand (e.g. Java 9 option on Java 7/8)
JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true"                   # don't try to start AWT. Not sure this does anything but better safe than wasting memory
JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8"                      # Use UTF-8
JAVA_OPTS="$JAVA_OPTS --add-opens=java.base/java.net=ALL-UNNAMED" # Allow dynamically adding JARs to classpath (Java 9)
JAVA_OPTS="$JAVA_OPTS --add-modules=java.xml.bind"                # Enable access to java.xml.bind module (Java 9)

JAVA_OPTS="$JAVA_OPTS -XX:+UseConcMarkSweepGC"
JAVA_OPTS="$JAVA_OPTS -Xmx256m"
JAVA_OPTS="$JAVA_OPTS -Xms256m"

echo "Using these JAVA_OPTS: ${JAVA_OPTS}"

PT_START="java $JAVA_OPTS -jar $PT_JAR"

[ -d "$PT_DIR" ] || mkdir -p "$PT_DIR" || {
   echo "Error: no $PT_DIR found and could not make it. Exiting."; exit -1;
}
unzip -joqd ${PT_DIR} ${PT_ZIP} ${PT}-${PT_VERSION}/${PT}.jar || {
  echo "Error: no $PT jar found. Exiting."; exit -1;
}
cd ${PT_DIR} || {
  echo "Error: problem with $PT_DIR. Exiting."; exit -1;
}

pcnt=$(/bin/ls -1 ${PT_DIR}/*.properties 2>/dev/null|/usr/bin/wc -l)
[[ ${pcnt} -gt 0 ]] || {
  echo "No properties found, extracting..."; unzip -jo ${PT_ZIP} -d ${PT_DIR};
  echo "Done! Now, edit your configuration files and reload the container."
  exit -1;
} || {
  echo "Error: no properties found and could not properly unzip $PT_ZIP. Exiting.";
  exit -1;
}

# start it
${PT_START}
