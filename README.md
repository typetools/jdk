# Typetools fork of the JDK

This fork of the JDK contains type annotations for pluggable type-checking.

It does *not* contain annotations for certain files (because annotations in
them cause build failures, especially in the interim builds):
 * the jdk.rmic module
 * objectweb/asm files
 * src/java.base/share/classes/java/time/*
 * src/jdk.compiler/share/classes/com/sun/tools/javac/*

Annotations for classes that exist in JDK 11 but were removed in JDK 17 appear
in jdk11.astub files in repository https://github.com/typetools/checker-framework/ .
Annotations for classes that exist in JDK 8 but were removed in JDK 11 appear
in jdk8.astub files in repository https://github.com/typetools/checker-framework/ .


## Building

See file `azure-pipelines.yml`.  Briefly:

```
bash configure --disable-warnings-as-errors --with-jtreg
make jdk
```

You might need to change `--with-jtreg` to one of these:
```
  --with-jtreg=/usr/share/jtreg
  --with-jtreg=$HOME/bin/install/jtreg
```


## Contributing

We welcome pull requests that add new annotations or correct existing ones.
Thanks in advance for your contributions!

When adding annotations, please annotate an entire file at a time, and add an
`@AnnotatedFor` annotation on the class declaration.  The rationale is explained
at https://checkerframework.org/manual/#library-tips-fully-annotate .


## Relationship to other repositories

This fork is not up to date with respect to `openjdk/jdk` (the current OpenJDK
version).  This fork contains all commits through the release of JDK 17 (that
is, the last commit that is in both openjdk/jdk and in openjdk/jdk17u; a way to
determine that is to run `git log --graph | tac` on both and find the common
prefix):
https://github.com/typetools/jdk/commit/74007890bb9a3fa3a65683a3f480e399f2b1a0b6

This fork is an ancestor of JDK release forks such as jdk17u.  This fork
does not compile, because the commit of `openjdk/jdk` on which it is based
no longer compiles, due to changes to tools such as compilers.
Repositories such as jdk11u and jdk17u have been updated and do compile.

This fork's annotations are pulled into those repositories, in order to
build an annotated JDK.  We do not write annotations in (say) jdk17u,
because it has diverged far from other repositories.  It would be even more
painful to write annotations on jdk17u and then try to merge it into a
subsequent version like jdk12u.


## Pull request merge conflicts

If a pull request is failing with a merge conflict in `jdk17u`, first
update jdk17u from its upstreams, using the directions in section
"The typetools/jdk17u repository" below.

If that does not resolve the issue, then do the following in a clone of the
branch of `jdk` whose pull request is failing.

[[TODO: These instructions need to be updated for JDK 17.]]

```
BRANCH=`git rev-parse --abbrev-ref HEAD`
URL=`git config --get remote.origin.url`
SLUG=${URL#*:}
ORG=${SLUG%/*}
JDK11DIR=../jdk17u-fork-$ORG-branch-$BRANCH
JDK17URL=`echo "$URL" | sed 's/jdk/jdk17u/'`
echo BRANCH=$BRANCH
echo URL=$URL
echo JDK11DIR=$JDK11DIR
echo JDK17URL=$JDK17URL
if [ -d $JDK11DIR ] ; then
  (cd $JDK11DIR && git pull)
else
  git clone $JDK17URL $JDK11DIR && (cd $JDK11DIR && (git checkout $BRANCH || git checkout -b $BRANCH))
fi
cd $JDK11DIR
git pull $URL $BRANCH
```

Manual step: resolve conflicts and complete the merge.

```
git push --set-upstream origin $BRANCH
```

Manual step: restart the pull request CI job.

After the pull request is merged to https://github.com/typetools/jdk,
follow the instructions at https://github.com/typetools/jdk17u to update
jdk17u, taking guidance from the merge done in the fork of jdk17u to
resolve conflicts.  Then, discard the branch in the fork of jdk17u.


## Qualifier definitions

The java.base module contains a copy of the Checker Framework qualifiers (type annotations).
To update that copy, run from this directory:

(cd $CHECKERFRAMEWORK && rm -rf checker-qual/build/libs && ./gradlew :checker-qual:sourcesJar) && \
rm -f checker-qual.jar && \
cp -p $CHECKERFRAMEWORK/checker-qual/build/libs/checker-qual-*-sources.jar checker-qual.jar && \
(cd src/java.base/share/classes && rm -rf org/checkerframework && \
  unzip ../../../../checker-qual.jar -x 'META-INF*' && \
  rm -f org/checkerframework/checker/signedness/SignednessUtilExtra.java && \
  chmod -R u+w org/checkerframework) && \
jar tf checker-qual.jar | grep '\.java$' | sed 's/\/[^/]*\.java/;/' | sed 's/\//./g' | sed 's/^/    exports /' | sort | uniq

Copy the exports lines that were printed by the last command to
src/java.base/share/classes/module-info.java .
Commit the changes, including the changed top-level `checker-qual.jar` file.


## The typetools/jdk17u repository

The typetools/jdk17u repository is a merge of `openjdk/jdk17u` and `typetools/jdk`.
That is, it is a fork of `openjdk/jdk17u`, with Checker Framework type annotations.

**Do not edit the `typetools/jdk17u` repository.**
Make changes in the `typetools/jdk` repository.
(Note that this README file appears in both the `typetools/jdk` and `typetools/jdk17u` repositories!)

To update jdk17u from its upstreams:
```
cd jdk17u
git pull
git pull https://github.com/openjdk/jdk17u.git
git pull https://github.com/typetools/jdk.git
```


## Design

The goal of this repository is to write Checker Framework annotations in
JDK source code.  In order to compile, it is necessary that definitions of
those annotations are available -- in a module such as java.base, or on the
classpath.  I tried putting them in `java.base` (which worked for JDK 11),
but I wasn't able to make that work for JDK 17.


## Upstream README follows

The remainder of this file is the `README.md` from `openjdk/jdk`.


# Welcome to the JDK!

For build instructions please see the
[online documentation](https://openjdk.java.net/groups/build/doc/building.html),
or either of these files:

- [doc/building.html](doc/building.html) (html version)
- [doc/building.md](doc/building.md) (markdown version)

See <https://openjdk.java.net/> for more information about
the OpenJDK Community and the JDK.
