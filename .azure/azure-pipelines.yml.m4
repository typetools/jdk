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
  container: mdernst/cf-ubuntu-jdk21-plus:latest
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

- job: build_jdk21u
  pool:
    vmImage: 'ubuntu-latest'
  container: mdernst/cf-ubuntu-jdk21-plus:latest
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
  # This creates ../jdk21u .
  # Run `git-clone-related` without a limit on depth, because if the depth is
  # too small, the merge will fail.  Don't use "--filter=blob:none" because that
  # leads to "fatal: remote error:  filter 'combine' not supported".
  - bash: |
      set -ex
      echo "pwd = $(pwd)"
      if test -d ../jdk21u; then
        echo "../jdk21u should not exist yet"
        false
      fi
      df .
      /tmp/$USER/git-scripts/git-clone-related typetools jdk21u ../jdk21u --single-branch
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git config --global core.longpaths true
      git config --global core.protectNTFS false
      cd ../jdk21u
      git diff --exit-code
      echo $?
    displayName: clone-related-jdk21u
  - bash: |
      cd ../jdk21u && git status
      eval $(/tmp/$USER/plume-scripts/ci-info typetools)
      set
      echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH_NAME}"
    displayName: git merge plan
  - bash: |
      set -ex
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git config --global pull.ff true
      git config --global pull.rebase false
      git config --global core.longpaths true
      git config --global core.protectNTFS false
      cd ../jdk21u && git status
      eval $(/tmp/$USER/plume-scripts/ci-info typetools)
      set
      echo "About to run: git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH_NAME}"
      cd ../jdk21u && git pull --no-edit https://github.com/${CI_ORGANIZATION}/jdk ${CI_BRANCH_NAME} || (git --version && git show | head -100 && git status && git diff | head -1000 && echo "Merge failed; see 'Pull request merge conflicts' at https://github.com/typetools/jdk/blob/master/README.md" && false)
    displayName: git merge
  - bash: cd ../jdk21u && export JT_HOME=/usr/share/jtreg && bash ./configure --with-jtreg --disable-warnings-as-errors
    displayName: configure
  - bash: cd ../jdk21u && make jdk
    displayName: make jdk
  ## This works only after `make images`
  # - bash: cd ../jdk21u && build/*/images/jdk/bin/java -version
  #   displayName: version
  # - bash: make -C /jdk21u run-test-tier1
  #   timeoutInMinutes: 0
  #   displayName: make run-test-tier1
  # - bash: make -C /jdk21u :test/jdk:tier1
  ## Temporarily comment out because of trouble finding junit and jasm
  # - bash: cd ../jdk21u && make run-test TEST="jtreg:test/jdk:tier1"
  #   timeoutInMinutes: 0
  #   displayName: make run-test

cftests_job(junit, cftests-junit, 11)
cftests_job(nonjunit, cftests-nonjunit, 11)
cftests_job(inference, cftests-inference, 11)
cftests_job(typecheck, typecheck, 11)
cftests_job(junit, cftests-junit, 17)
cftests_job(nonjunit, cftests-nonjunit, 17)
cftests_job(inference, cftests-inference, 17)
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
