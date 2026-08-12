# DO NOT EDIT azure-pipelines.yml.  Edit azure-pipelines.yml.m4 and defs.m4 instead.

changequote
changequote(`[',`]')dnl
include([defs.m4])dnl
variables:
  system.debug: true

jobs:

  - job: build_jdk
    pool:
      vmImage: 'ubuntu-latest'
    container: mdernst/cf-ubuntu-jdk[]jdk_version-plus:latest
    steps:
      - bash: |
          whoami
          git config --get remote.origin.url
          pwd
          ls -al
          env | sort
        displayName: show environment
      - bash: pwd && ls && bash ./configure --with-jtreg=/usr/share/jtreg --disable-warnings-as-errors
        displayName: configure
      - bash: make jdk
        timeoutInMinutes: 90
        displayName: make jdk
        ## This works only after `make images`
        # - bash: build/*/images/jdk/bin/java -version
        #   displayName: version
        ## Don't run tests, which pass only with old version of tools (compilers, etc.).
        # - bash: make -C /jdk run-test-tier1
        #   displayName: make run-test-tier1

  - job: build_jdk[]jdku_version
    pool:
      vmImage: 'ubuntu-latest'
    container: mdernst/cf-ubuntu-jdk[]jdk_version-plus:latest
    timeoutInMinutes: 0
    steps:
      - bash: |
          whoami
          git config --get remote.origin.url
          pwd
          ls -al
          env | sort
        displayName: show environment
      - bash: |
          set -ex
          if test -d /tmp/$USER/git-scripts ; \
            then git -C /tmp/$USER/git-scripts pull -q > /dev/null 2>&1 ; \
            else mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/git-scripts.git ; \
          fi
        displayName: git-scripts
      - bash: |
          set -ex
          if test -d /tmp/$USER/plume-scripts ; \
            then git -C /tmp/$USER/plume-scripts pull -q > /dev/null 2>&1 ; \
            else mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/plume-scripts.git ; \
          fi
        displayName: plume-scripts
        # This creates ../jdk[]jdku_version .
        # Run `git-clone-related` without a limit on depth, because if the depth is
        # too small, the merge will fail.  Don't use "--filter=blob:none" because that
        # leads to "fatal: remote error:  filter 'combine' not supported".
      - bash: |
          set -ex
          echo "pwd = $(pwd)"
          if test -d ../jdk[]jdku_version; then
            echo "../jdk[]jdku_version should not exist yet"
            false
          fi
          df .
          /tmp/$USER/git-scripts/git-clone-related typetools jdk[]jdku_version ../jdk[]jdku_version --single-branch
          git config --global user.email "you@example.com"
          git config --global user.name "Your Name"
          git config --global core.longpaths true
          git config --global core.protectNTFS false
          cd ../jdk[]jdku_version
          git diff --exit-code
        displayName: clone-related-jdk[]jdku_version
      - bash: |
          git config --global --add safe.directory $(cd ../jdk[]jdku_version && pwd)
          cd ../jdk[]jdku_version && git status
          /tmp/$USER/plume-scripts/ci-org-and-branch typetools --debug
          eval $(/tmp/$USER/plume-scripts/ci-org-and-branch typetools)
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH}"
        displayName: git merge plan
      - bash: |
          set -ex
          git config --global user.email "you@example.com"
          git config --global user.name "Your Name"
          git config --global pull.ff true
          git config --global pull.rebase false
          git config --global core.longpaths true
          git config --global core.protectNTFS false
          git config --global merge.conflictstyle diff3
          cd ../jdk[]jdku_version && git status
          eval $(/tmp/$USER/plume-scripts/ci-org-and-branch typetools)
          echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH}"
          cd ../jdk[]jdku_version && git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH} || (git --version && git show | head -100 && git status && git diff | head -1000 && echo "Merge failed; see 'Pull request merge conflicts' at https://github.com/typetools/jdk/blob/master/README.md " && false)
        displayName: git merge
      - bash: cd ../jdk[]jdku_version && export JT_HOME=/usr/share/jtreg && bash ./configure --with-jtreg --disable-warnings-as-errors
        displayName: configure
      - bash: cd ../jdk[]jdku_version && make jdk
        displayName: make jdk
        ## This works only after `make images`
        # - bash: cd ../jdk[]jdku_version && build/*/images/jdk/bin/java -version
        #   displayName: version
        # - bash: make -C /jdk[]jdku_version run-test-tier1
        #   timeoutInMinutes: 0
        #   displayName: make run-test-tier1
        # - bash: make -C /jdk[]jdku_version :test/jdk:tier1
        ## Temporarily comment out because of trouble finding junit and jasm
        # - bash: cd ../jdk[]jdku_version && make run-test TEST="jtreg:test/jdk:tier1"
        #   timeoutInMinutes: 0
        #   displayName: make run-test

  - job: canary_jobs
    dependsOn:
      - build_jdk
      - build_jdk[]jdku_version
    pool:
      vmImage: 'ubuntu-latest'
    steps:
      - bash: true
        displayName: canary_jobs

include([jobs.m4])dnl

ifelse([
Local Variables:
eval: (add-hook 'after-save-hook '(lambda () (run-command nil "make")) nil 'local)
end:
])dnl
