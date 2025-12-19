# Typetools fork of the JDK

This fork of the JDK contains type annotations for pluggable type-checking.
It is called "the annotated JDK".

It does *not* contain annotations for certain files (because annotations in
them cause build failures, especially in the interim builds):

* the jdk.rmic module
* objectweb/asm files
* src/java.base/share/classes/java/time/*
* src/jdk.compiler/share/classes/com/sun/tools/javac/*

Annotations for classes that exist in JDK version X but were removed later
appear in jdkX.astub files, such as jdk11.astub, in repository
<https://github.com/typetools/checker-framework/> .

## Building

You **do not need to build** the annotated JDK in order to use it in the Checker
Framework.

Put the annotated JDK in a directory named `jdk/` that is a sibling of your
`checker-framework/` directory.  Now, when you build the Checker Framework
(e.g., `cd checker-framework && ./gradlew assemble`), it will automatically
incorporate the annotated JDK into the resulting Checker Framework binaries.
The `jdk/` and `checker-framework/` directories can be clones of the relevant
repositories, or they can be (hard or soft) symbolic links to the clones.

If there is a mistake in an annotated JDK file (such as a typo in an annotation
name or a missing `import` statement), the entire file is ignored.  CI builds
the JDK in order to detect such errors.

If you want to build the JDK rather than just use it from the Checker Framework,
see file `.azure/azure-pipelines.yml`.  Briefly:

```sh
bash configure --disable-warnings-as-errors --with-jtreg
make jdk
```

You might need to change `--with-jtreg` to one of these:

```sh
  --with-jtreg=/usr/share/jtreg
  --with-jtreg=$HOME/bin/install/jtreg
```

## Contributing

We welcome pull requests that add new annotations or correct existing ones.
Thanks in advance for your contributions!

When adding annotations, please annotate an entire file at a time, and add an
`@AnnotatedFor` annotation on the class declaration.  The rationale is explained
at <https://checkerframework.org/manual/#library-tips-fully-annotate> .

## Relationship to other repositories

The typetools:jdk fork is not up to date with respect to `openjdk:jdk` (the
current OpenJDK version).  The typetools:jdk fork contains all commits through
the release of JDK 21 (that is, the last commit that is in both openjdk:jdk and
in openjdk:jdk21u):
<https://github.com/typetools/jdk/commit/d562d3fcbe22a0443037c5b447e1a41401275814>

The typetools:jdk fork is an ancestor of JDK release forks such as
typetools:jdk21u.  The typetools:jdk fork may not compile, because the commit of
openjdk:jdk on which it is based may not compile, due to changes to tools such
as compilers.  Repositories such as jdk11u, jdk17u, and jdk21u have been updated
and do compile.

This fork's annotations are pulled into those repositories, in order to build an
annotated JDK.  We do not write annotations in (say) typetools:jdk21u, because
it would be painful to get them into typetools:jdk21u due to subsequent commits.

## Pull request merge conflicts

If a pull request is failing with a merge conflict in `jdk21u`, first
update jdk21u from its upstreams, using the directions in section
"The typetools/jdk21u repository" below.

If that does not resolve the issue, then do the following in a clone of the
branch of `jdk` whose pull request is failing.

<!-- markdownlint-disable line-length -->

```sh
BRANCH=`git rev-parse --abbrev-ref HEAD`
URL=`git config --get remote.origin.url`
SLUG=${URL#*:}
ORG=${SLUG%/*}
JDK21DIR=../jdk21u-fork-$ORG-branch-$BRANCH
JDK21URL=`echo "$URL" | sed 's/jdk/jdk21u/'`
echo BRANCH=$BRANCH
echo URL=$URL
echo JDK21DIR=$JDK21DIR
echo JDK21URL=$JDK21URL
if [ -d $JDK21DIR ] ; then
  (cd $JDK21DIR && git pull)
else
  git clone $JDK21URL $JDK21DIR && (cd $JDK21DIR && (git checkout $BRANCH || git checkout -b $BRANCH))
fi
cd $JDK21DIR
git pull $URL $BRANCH
```

Manual step: resolve conflicts and complete the merge.

```sh
git push --set-upstream origin $BRANCH
```

Manual step: restart the pull request CI job.

After the pull request is merged to <https://github.com/typetools/jdk>,
follow the instructions at <https://github.com/typetools/jdk21u> to update
jdk21u, taking guidance from the merge done in the fork of jdk21u to
resolve conflicts.  Then, discard the branch in the fork of jdk21u.

## Qualifier definitions

The java.base module contains a copy of the Checker Framework qualifiers (type annotations).
To update that copy, run the command below from this directory:

```sh
(cd $CHECKERFRAMEWORK && rm -rf checker-qual/build/libs && ./gradlew :checker-qual:sourcesJar) && \
rm -f checker-qual.jar && \
cp -p $CHECKERFRAMEWORK/checker-qual/build/libs/checker-qual-*-sources.jar checker-qual.jar && \
(cd src/java.base/share/classes && rm -rf org/checkerframework && \
  unzip ../../../../checker-qual.jar -x 'META-INF*' && \
  rm -f org/checkerframework/checker/signedness/SignednessUtilExtra.java && \
  chmod -R u+w org/checkerframework) && \
jar tf checker-qual.jar | grep '\.java$' | sed 's/\/[^/]*\.java/;/' | sed 's/\//./g' | sed 's/^/    exports /' | sort -u
```

The result of the command will be a list of export lines.
Replace the existing export lines present in
`src/java.base/share/classes/module-info.java` with the newly-generated list of
exports. If no new packages were added, then likely no changes are needed
in the `module-info.java` file.

Commit the changes, including the new `checker.jar` file and any new `.java`
files in a `qual/` directory.  (Both are used, by different parts of the build.)

## The typetools/jdk21u repository

The typetools/jdk21u repository is a merge of `openjdk/jdk21u` and `typetools/jdk`.
That is, it is a fork of `openjdk/jdk21u`, with Checker Framework type annotations.

**Do not edit the `typetools/jdk21u` repository.**
Make changes in the `typetools/jdk` repository.
(Note that this README file appears in both the `typetools/jdk`
and `typetools/jdk21u` repositories!)

To update jdk21u from its upstreams:
(These are the only edits to jdk21u allowed, plus changes needed to resolve
merge conflicts.)

```sh
cd jdk21u
git pull
git pull https://github.com/openjdk/jdk21u.git
git pull https://github.com/typetools/jdk.git
```

## Upgrading to a new version of Java

Whenever Oracle releases a new version of Java, this repository should be
updated to pull in more commits from upstream.  Here are some commands to run
when updating to JDK ${VER}.

Fork into typetools:  <https://github.com/openjdk/jdk${VER}u>

Clone jdk${VER}u repositories into, say, $t/libraries/ .

Determine the last commit in both openjdk:jdk and in openjdk:jdk${VER}u:  run

```sh
git log --graph | tac > git-log-reversed.txt
```

on both and find the common prefix.

```sh
VER=21
last_common_commit=bb377b26730f3d9da7c76e0d171517e811cef3ce
cd $t/libraries
git clone -- git@github.com:openjdk/jdk.git jdk-fork-openjdk-commit-${last_common_commit}
cd jdk-fork-openjdk-commit-${last_common_commit}
git reset --hard ${last_common_commit}

cd $t/libraries/jdk-fork-${USER}-branch-jdk${VER}
git pull ../jdk-fork-openjdk-commit-${last_common_commit}
```

Resolve the merge conflicts.  The commands in `README-merging.el` automate a
great deal of work (requires using Emacs).

Replace uses of the old JDK version (such as 17) with the new one (such as 21).

* In this file
* In .azure/azure-pipelines.yml.m4

Make a fork of jdk21u.  Follow the instructions in "The typetools/jdk21u
repository" above, except replace
`git pull https://github.com/typetools/jdk.git` 
by the JDK you are currently working on.

Build JDK 21u (not the main JDK!).

Diff JDK 21 with the upstream commit of OpenJDK, to detect unintentional edits.
The commands in `README-diffing.el` automate a great deal of work (requires
using Emacs).

```sh
cd jdk21u-fork-typetools
git pull ../jdk-fork-${USER}-branch-jdk21
```

Push and wait for CI to pass.

Find all `.java` files that contain both `@AnnotatedFor` and a relevant `@since`
in Javadoc.  For example, the regex "@since[ \t](18|19|20|21)".  For each
relevant `@since`, add annotations for all the type systems in `@AnnotatedFor`.
Note: I have not yet done this for JDK 18-21.

DO NOT squash-and-merge the pull request.  Both the jdk and jdk21u repositories
need to be merged, retaining history.

For Michael Ernst only:  update `~/bin/src/mdedots/share/mdevcupdate`
to refer to jdk21u, not jdk17u.

## Design

The goal of this repository is to write Checker Framework annotations in
JDK source code.  In order to compile, it is necessary that definitions of
those annotations are available -- in a module such as java.base, or on the
classpath.  Putting them in `java.base` worked for JDK 11,
but I wasn't able to make that work for JDK 17.

## Upstream README follows

The remainder of this file is the `README.md` from `openjdk/jdk`.

# Welcome to the JDK

For build instructions please see the
[online documentation](https://openjdk.org/groups/build/doc/building.html),
or either of these files:

* [doc/building.html](doc/building.html) (html version)
* [doc/building.md](doc/building.md) (markdown version)

See <https://openjdk.org/> for more information about the OpenJDK
Community and the JDK and see <https://bugs.openjdk.org> for JDK issue
tracking.
