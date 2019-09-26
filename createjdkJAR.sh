#! /bin/bash

# This script creates a directory named 'jdk11' containing JARs of compiled Annotated-JDK modules.
# The directory containing these JARs will be uploaded to maven central as zip to be used with build tools like Maven/Gradle/Bazel
JAVAVERSION=11

# Remove previously present files.
rm -r jdk${JAVAVERSION}

# Create the jdk directory to place the JAR files and Patch_Module_argfile
mkdir jdk${JAVAVERSION}
touch jdk${JAVAVERSION}/Patch_Modules_argfile

# TODO: SHUBHAM : Modify the logic to only create JAR of those module which create Checker Framework's Annotation.
# Above should be implemented after discussion or creation of Checker Framework's Maven Plugin where we can update the addition
# of new --patch-module argument through an update to the Maven/Gradle plugin itself.
for i in `find ./build/*/jdk/modules -maxdepth 1 -mindepth 1 -type d` ; do
  echo "Coverting `basename $i` to jar"
  jar --create --file=$i.annotated.jar --module-version=1.0 -C $i .
  # Add arguments for patching modules to Patch_Module_argfile
  echo "--patch-module `basename $i`=\${CURRENT_JDK_FOLDER}/`basename $i`.annotated.jar" >> jdk${JAVAVERSION}/Patch_Modules_argfile
  mv ./build/*/jdk/modules/`basename $i`.annotated.jar ./jdk${JAVAVERSION}/
done
