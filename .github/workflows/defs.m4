changequote
changequote(`[',`]')dnl

define([canary_os], [ubuntu])dnl
define([canary_version], [25])dnl
define([latest_version], [25])dnl
define([canary_test], [canary_os[]canary_version])dnl

define([cftests_job], [dnl
  cftests_$1_jdk$3:
    needs:
      - canary_jobs
    timeout-minutes: 120
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk$3:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 25
      - name: clone git-scripts
        run: mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/git-scripts.git
      - name: clone checker-framework
        run: /tmp/$USER/git-scripts/git-clone-related typetools checker-framework
      - name: test-$2.sh
        run: (cd ../checker-framework && checker/bin-devel/test-$2.sh)])dnl

define([daikon_job], [dnl
  test_daikon_part$1:
    needs:
      - canary_jobs
    timeout-minutes: 70
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk17:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 25
      - name: clone git-scripts
        run: mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/git-scripts.git
      - name: clone checker-framework
        run: /tmp/$USER/git-scripts/git-clone-related typetools checker-framework
      - name: test-daikon-part$1.sh
        run: (cd ../checker-framework && checker/bin-devel/test-daikon-part$1.sh)])dnl

define([plume_lib_job], [dnl
  test_plume_lib:
    needs:
      - canary_jobs
    runs-on: ubuntu-latest
    container: mdernst/cf-ubuntu-jdk17:latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 25
      - name: clone git-scripts
        run: mkdir -p /tmp/$USER && git -C /tmp/$USER clone --depth=1 -q https://github.com/plume-lib/git-scripts.git
      - name: clone checker-framework
        run: /tmp/$USER/git-scripts/git-clone-related typetools checker-framework
      - name: test-plume-lib.sh
        run: (cd ../checker-framework && checker/bin-devel/test-plume-lib.sh)])dnl

ifelse([
Local Variables:
eval: (add-hook 'after-save-hook '(lambda () (run-command nil "make")) nil 'local)
end:
])dnl
