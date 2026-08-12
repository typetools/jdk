# DO NOT EDIT ci.yml.  Edit ci.yml.m4 and defs.m4 instead.

changequote
changequote(`[',`]')dnl
include([defs.m4])dnl

name: CF CI

on:
  push:
  pull_request:
  workflow_dispatch:

defaults:
  run:
    shell: bash --noprofile --norc -eo pipefail {0}

jobs:
  check_generated_ci:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v7
      - name: Check generated ci.yml
        run: make -B -C .github/workflows && git diff --exit-code -- .github/workflows/ci.yml

  build_jdk:
    needs:
      - check_generated_ci
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk[]jdk_version-plus:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v7
      - name: show environment
        run: |
          whoami
          git config --get remote.origin.url || true
          pwd
          ls -al
          echo "HOME=${HOME}"
          echo "USER=${USER}"
          echo "SHELL=${SHELL}"
          echo "GITHUB_WORKSPACE=${GITHUB_WORKSPACE}"
      - name: configure
        run: |
          pwd
          bash ./configure --with-jtreg=/usr/share/jtreg --disable-warnings-as-errors
      - name: make jdk
        timeout-minutes: 90
        run: make jdk

  build_jdk[]jdku_version:
    if: endsWith(github.repository, '/jdk')
    needs:
      - check_generated_ci
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk[]jdk_version-plus:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v7
      - name: show environment
        run: |
          whoami
          git config --get remote.origin.url || true
          pwd
          ls -al
          echo "HOME=${HOME}"
          echo "USER=${USER}"
          echo "SHELL=${SHELL}"
          echo "GITHUB_WORKSPACE=${GITHUB_WORKSPACE}"
      - name: clone git-scripts
        run: |
          set -ex
          if test -d /tmp/$USER/git-scripts ; \
            then git -C /tmp/$USER/git-scripts pull -q > /dev/null 2>&1 ; \
            else mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/git-scripts.git ; \
          fi
      - name: clone plume-scripts
        run: |
          set -ex
          if test -d /tmp/$USER/plume-scripts ; \
            then git -C /tmp/$USER/plume-scripts pull -q > /dev/null 2>&1 ; \
            else mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/plume-scripts.git ; \
          fi
      - name: git config
        run: |
          git config --global user.email "you@example.com"
          git config --global user.name "Your Name"
          git config --global pull.ff true
          git config --global pull.rebase false
          git config --global core.longpaths true
          git config --global core.protectNTFS false
          git config --global --add safe.directory /__w/jdk/jdk
          git config --global merge.conflictstyle diff3
        # This creates ../jdk[]jdku_version .
        # Run `git-clone-related` without a limit on depth, because if the depth is
        # too small, the merge will fail.  Don't use "--filter=blob:none" because that
        # leads to "fatal: remote error:  filter 'combine' not supported".
      - name: ci-org-and-branch
        run: /tmp/$USER/plume-scripts/ci-org-and-branch --debug
      - name: clone-related-jdk[]jdku_version
        run: |
          set -ex
          echo "pwd = $(pwd)"
          if test -d ../jdk[]jdku_version; then
            echo "../jdk[]jdku_version should not exist yet"
            false
          fi
          df .
          /tmp/$USER/git-scripts/git-clone-related typetools jdk[]jdku_version ../jdk[]jdku_version --single-branch
          cd ../jdk[]jdku_version
          git diff --exit-code
      - name: git merge plan
        run: |
          set -ex
          cd ../jdk[]jdku_version
          git status
          /tmp/$USER/plume-scripts/ci-org-and-branch typetools --debug
          eval $(/tmp/$USER/plume-scripts/ci-org-and-branch typetools)
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH}"
        shell: bash --noprofile --norc -e {0}
      - name: git merge
        run: |
          set -ex
          cd ../jdk[]jdku_version
          eval $(/tmp/$USER/plume-scripts/ci-org-and-branch typetools)
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH}"
          if ! git pull --no-edit "https://github.com/${CI_ORGANIZATION}/jdk" "${CI_BRANCH}"; then
            git --version
            git show | head -100
            git status && git diff | head -1000
            echo "Merge failed; see 'Pull request merge conflicts' at https://github.com/typetools/jdk/blob/master/README.md"
            false
          fi
        shell: bash --noprofile --norc -e {0}
      - name: configure
        run: |
          cd ../jdk[]jdku_version
          export JT_HOME=/usr/share/jtreg
          bash ./configure --with-jtreg --disable-warnings-as-errors
      - name: make jdk
        timeout-minutes: 90
        run: make -C ../jdk[]jdku_version jdk

  canary_jobs:
    needs:
      - build_jdk
      - build_jdk[]jdku_version
    runs-on: ubuntu-latest
    steps:
      - name: canary_jobs
        run: true

include([../../.azure/jobs.m4])dnl

ifelse([
Local Variables:
eval: (add-hook 'after-save-hook '(lambda () (run-command nil "make")) nil 'local)
end:
])dnl
