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
        with:
          fetch-depth: 1
          show-progress: false
          persist-credentials: false
      - name: Check generated ci.yml
        run: make -B -C .github/workflows && git diff --exit-code -- .github/workflows/ci.yml

  build_jdk:
    needs:
      - check_generated_ci
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk21-plus:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v7
        with:
          fetch-depth: 1
          show-progress: false
          persist-credentials: false
      - name: show environment
        run: |
          whoami
          git config --get remote.origin.url || true
          pwd
          ls -al
          set
      - name: configure
        run: |
          pwd
          bash ./configure --with-jtreg=/usr/share/jtreg --disable-warnings-as-errors
      - name: make jdk
        timeout-minutes: 90
        run: make jdk

  build_jdk21u:
    if: endsWith(github.repository, '/jdk')
    needs:
      - check_generated_ci
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk21-plus:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v7
        with:
          fetch-depth: 1
          show-progress: false
          persist-credentials: false
      - name: show environment
        run: |
          whoami
          git config --get remote.origin.url || true
          pwd
          ls -al
          set
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
        # This creates ../jdk21u .
        # Run `git-clone-related` without a limit on depth, because if the depth is
        # too small, the merge will fail.  Don't use "--filter=blob:none" because that
        # leads to "fatal: remote error:  filter 'combine' not supported".
      - name: set-ci-org-and-branch
        run: |
          # shellcheck disable=SC2034  # used by the sourced script
          CI_DEBUG=1
          . /tmp/$USER/plume-scripts/set-ci-org-and-branch
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
        # Source `set-ci-org-and-branch` in this repository's checkout, not in
        # ../jdk21u.  Outside a pull request, the script falls back to the
        # organization of the current clone's origin, and ../jdk21u's origin is
        # the related repository (typetools/jdk21u, if this branch does not
        # exist in the fork) rather than the repository under test.
      - name: git merge plan
        run: |
          set -ex
          # shellcheck disable=SC2034  # used by the sourced script
          CI_DEFAULT_ORGANIZATION=typetools
          # shellcheck disable=SC2034  # used by the sourced script
          CI_DEBUG=1
          . /tmp/$USER/plume-scripts/set-ci-org-and-branch
          cd ../jdk21u
          git status
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH}"
        shell: bash --noprofile --norc -e {0}
      - name: git merge
        run: |
          set -ex
          # shellcheck disable=SC2034  # used by the sourced script
          CI_DEFAULT_ORGANIZATION=typetools
          . /tmp/$USER/plume-scripts/set-ci-org-and-branch
          cd ../jdk21u
          jdk21u_url=$(git config --get remote.origin.url)
          jdk21u_branch=$(git rev-parse --abbrev-ref HEAD)
          jdk21u_commit=$(git rev-parse HEAD)
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH}"
          if ! git pull --no-edit "https://github.com/${CI_ORGANIZATION}/jdk" "${CI_BRANCH}"; then
            git --version
            merge_head=$(git rev-parse --verify --quiet MERGE_HEAD) || merge_head=
            echo "Merge into ${jdk21u_url} branch ${jdk21u_branch} :"
            git --no-pager log -1 --format='  %H %cd %s' --date=iso "${jdk21u_commit}"
            echo "Merge from https://github.com/${CI_ORGANIZATION}/jdk branch ${CI_BRANCH} :"
            if test -n "${merge_head}"; then
              git --no-pager log -1 --format='  %H %cd %s' --date=iso "${merge_head}"
              echo "Merge base:"
              git --no-pager log -1 --format='  %H %cd %s' --date=iso "$(git merge-base "${jdk21u_commit}" "${merge_head}")"
            else
              echo "  unknown; the merge did not start"
            fi
            git status && git diff | head -1000
            echo "Merge failed; see 'Pull request merge conflicts' at https://github.com/typetools/jdk/blob/master/README.md"
            false
          fi
        shell: bash --noprofile --norc -e {0}
      - name: configure
        run: |
          cd ../jdk21u
          export JT_HOME=/usr/share/jtreg
          bash ./configure --with-jtreg --disable-warnings-as-errors
      - name: make jdk
        timeout-minutes: 90
        run: make -C ../jdk21u jdk

  canary_jobs:
    needs:
      - build_jdk
      - build_jdk21u
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
