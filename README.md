# Typetools fork of the JDK

This fork of the JDK contains type annotations for pluggable type-checking.

It does *not* contain annotations for certain files (because annotations in
them cause build failures, especially in the interim builds):
 * the jdk.rmic module
 * objectweb/asm files
 * src/java.base/share/classes/java/time/*
 * src/jdk.compiler/share/classes/com/sun/tools/javac/*

Annotations for classes that exist in JDK version X but were removed later
appear in jdkX.astub files, such as jdk11.astub, in repository
https://github.com/typetools/checker-framework/ .


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

The typetools:jdk fork is not up to date with respect to `openjdk:jdk` (the
current OpenJDK version).  The typetools:jdk fork contains all commits through
the release of JDK 20 (that is, the last commit that is in both openjdk:jdk and
in openjdk:jdk20u):
https://github.com/typetools/jdk/commit/d562d3fcbe22a0443037c5b447e1a41401275814

The typetools:jdk fork is an ancestor of JDK release forks such as
typetools:jdk17u.  The typetools:jdk fork may not compile, because the commit of
openjdk:jdk on which it is based may not compile, due to changes to tools such
as compilers.  Repositories such as jdk11u, jdk17u, and jdk20u have been updated
and do compile.

This fork's annotations are pulled into those repositories, in order to build an
annotated JDK.  We do not write annotations in (say) typetools:jdk20u, because
it would be painful to get them into typetools:jdk21u due to subsequent commits.


## Pull request merge conflicts

If a pull request is failing with a merge conflict in `jdk17u`, first
update jdk17u from its upstreams, using the directions in section
"The typetools/jdk17u repository" below.

If that does not resolve the issue, then do the following in a clone of the
branch of `jdk` whose pull request is failing.

```
BRANCH=`git rev-parse --abbrev-ref HEAD`
URL=`git config --get remote.origin.url`
SLUG=${URL#*:}
ORG=${SLUG%/*}
JDK17DIR=../jdk17u-fork-$ORG-branch-$BRANCH
JDK17URL=`echo "$URL" | sed 's/jdk/jdk17u/'`
echo BRANCH=$BRANCH
echo URL=$URL
echo JDK17DIR=$JDK17DIR
echo JDK17URL=$JDK17URL
if [ -d $JDK17DIR ] ; then
  (cd $JDK17DIR && git pull)
else
  git clone $JDK17URL $JDK17DIR && (cd $JDK17DIR && (git checkout $BRANCH || git checkout -b $BRANCH))
fi
cd $JDK17DIR
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
To update that copy, run the command below from this directory:

```
(cd $CHECKERFRAMEWORK && rm -rf checker-qual/build/libs && ./gradlew :checker-qual:sourcesJar) && \
rm -f checker-qual.jar && \
cp -p $CHECKERFRAMEWORK/checker-qual/build/libs/checker-qual-*-sources.jar checker-qual.jar && \
(cd src/java.base/share/classes && rm -rf org/checkerframework && \
  unzip ../../../../checker-qual.jar -x 'META-INF*' && \
  rm -f org/checkerframework/checker/signedness/SignednessUtilExtra.java && \
  chmod -R u+w org/checkerframework) && \
jar tf checker-qual.jar | grep '\.java$' | sed 's/\/[^/]*\.java/;/' | sed 's/\//./g' | sed 's/^/    exports /' | sort | uniq
```
The result of the command will be a list of export lines.
Replace the existing export lines present in
`src/java.base/share/classes/module-info.java` with the newly-generated list of
exports. If no new packages were added, then there are likely going to be no
changes to the `module-info.java` file.

Check that all the changes are desirable.
Commit the changes, including the new `checker.jar` file and any new `.java`
files in a `qual/` directory.  (Both are used, by different parts of the build.)


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


## Updating

Whenever a new Java release is made, this repository should be updated to pull in more commits from upstream.  Here are some commands to run when updating to JDK ${VER}.

Fork into typetools:  https://github.com/openjdk/jdk${VER}u

Clone jdk${VER}u repositories into, say, $t/libraries/ .

Determine the last commit in both openjdk:jdk and in openjdk:jdk${VER}u:
run `git log --graph | tac` on both and find the common prefix.

```
last_common_commit=d562d3fcbe22a0443037c5b447e1a41401275814
cd $t/libraries
git clone -- git@github.com:openjdk/jdk.git jdk-fork-openjdk-commit-${last_common_commit}
cd jdk-fork-openjdk-commit-${last_common_commit}
git reset --hard ${last_common_commit}

cd $t/libraries/jdk-fork-${USER}-branch-jdk${VER}
git pull ../jdk-fork-openjdk-commit-${last_common_commit}
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
