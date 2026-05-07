# DO NOT EDIT ci.yml.  Edit ci.yml.m4 and defs.m4 instead.

changequote
changequote(`[',`]')dnl
include([defs.m4])dnl

name: CI

on:
  push:
  pull_request:
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

defaults:
  run:
    shell: bash --noprofile --norc -eo pipefail {0}

jobs:
  check_generated_ci:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5
      - name: Check generated ci.yml
        run: make -B -C .github/workflows && git diff --exit-code -- .github/workflows/ci.yml

  build_jdk:
    needs:
      - check_generated_ci
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk21-plus:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5
      - name: show environment
        run: |
          whoami
          git config --get remote.origin.url || true
          pwd
          ls -al
          env | sort
      - name: configure
        run: pwd && ls && bash ./configure --with-jtreg=/usr/share/jtreg --disable-warnings-as-errors
      - name: make jdk
        timeout-minutes: 90
        run: make jdk

  build_jdk21u:
    needs:
      - check_generated_ci
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk21-plus:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5
      - name: show environment
        run: |
          whoami
          git config --get remote.origin.url || true
          pwd
          ls -al
          env | sort
      - name: git-scripts
        run: |
          set -ex
          if test -d /tmp/$USER/git-scripts ; \
            then git -C /tmp/$USER/git-scripts pull -q > /dev/null 2>&1 ; \
            else mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/git-scripts.git ; \
          fi
      - name: plume-scripts
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
        # This creates ../jdk21u .
        # Run `git-clone-related` without a limit on depth, because if the depth is
        # too small, the merge will fail.  Don't use "--filter=blob:none" because that
        # leads to "fatal: remote error:  filter 'combine' not supported".
      - name: clone-related-jdk21u
        run: |
          set -ex
          echo "pwd = $(pwd)"
          if test -d ../jdk21u; then
            echo "../jdk21u should not exist yet"
            false
          fi
          df .
          /tmp/$USER/git-scripts/git-clone-related typetools jdk21u ../jdk21u --single-branch
          cd ../jdk21u
          git diff --exit-code
          echo $?
      - name: git merge plan
        run: |
          cd ../jdk21u && git status
          eval $(/tmp/$USER/plume-scripts/ci-info typetools)
          printf 'CI_ORGANIZATION=%s\n' "${CI_ORGANIZATION}"
          printf 'CI_BRANCH_NAME=%s\n' "${CI_BRANCH_NAME}"
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH_NAME}"
      - name: git merge
        run: |
          set -ex
          cd ../jdk21u && git status
          eval $(/tmp/$USER/plume-scripts/ci-info typetools)
          printf 'CI_ORGANIZATION=%s\n' "${CI_ORGANIZATION}"
          printf 'CI_BRANCH_NAME=%s\n' "${CI_BRANCH_NAME}"
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH_NAME}"
          cd ../jdk21u && git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH_NAME} || (git --version && git show | head -100 && git status && git diff | head -1000 && echo "Merge failed; see 'Pull request merge conflicts' at https://github.com/typetools/jdk/blob/master/README.md " && false)
      - name: configure
        run: cd ../jdk21u && export JT_HOME=/usr/share/jtreg && bash ./configure --with-jtreg --disable-warnings-as-errors
      - name: make jdk
        run: cd ../jdk21u && make jdk

  canary_jobs:
    needs:
      - build_jdk
      - build_jdk21u
    runs-on: ubuntu-latest
    steps:
      - name: canary_jobs
        run: true

cftests_job(junit, cftests-junit, 17)
cftests_job(nonjunit, cftests-nonjunit, 17)
cftests_job(typecheck, typecheck, 17)
cftests_job(junit, cftests-junit, 21)
cftests_job(nonjunit, cftests-nonjunit, 21)
cftests_job(inference, cftests-inference, 21)
cftests_job(typecheck, typecheck, 21)
cftests_job(junit, cftests-junit, 25)
cftests_job(nonjunit, cftests-nonjunit, 25)
cftests_job(inference, cftests-inference, 25)
cftests_job(typecheck, typecheck, 25)

daikon_job(1)
daikon_job(2)
daikon_job(3)

plume_lib_job(canary_version)

ifelse([
Local Variables:
eval: (add-hook 'after-save-hook '(lambda () (run-command nil "make")) nil 'local)
end:
])dnl
