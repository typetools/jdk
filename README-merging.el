;; This file contains editor commands that are helpful when merging the JDK.

;; Run at the top level: etags $(rg --files-with-matches '<<<<<<')
;; Then, visit that tags table and run these expressions.

;; To fix Java array declarations from
;; "short a2[]" to "short[] a2" or from
;; "@PolySigned short a2 @Nullable []" to "@PolySigned short @Nullable [] a2":
(tags-query-replace "\\([^@]\\)\\b\\([A-Z][a-z][A-Za-z0-9]+\\|byte\\|short\\|int\\|long\\|float\\|double\\|boolean\\|char\\) \\([A-Za-z0-9]+\\)\\(\\( ?@[A-Za-z0-9]+ ?\\)*\\[\\]\\)" "\\1\\2\\4 \\3")

(defvar annotation-line-regex)
(setq annotation-line-regex
      " *@\\(CallerSensitive\\|ForceInline\\|Override\\|Covariant({[0-9]})\\|CreatesMustCallFor\\|Deterministic\\|EqualsMethod\\|ForName\\|FormatMethod\\|GetConstructor\\|GetClass\\|GetMethod\\|InheritableMustCall(.*)\\|I18nMakeFormat\\|Invoke\\|MayReleaseLocks\\|MustCall(.*)\\|NewInstance\\|NotOwning\\|OptionalCreator\\|OptionalEliminator\\|OptionalPropagator\\|PolyUIEffect\\|PolyUIType\\|Pure\\|ReleasesNoLocks\\|SafeEffect\\|SideEffectFree\\|SideEffectsOnly.*\\|StaticallyExecutable\\|TerminatesExecution\\|UIEffect\\|UIPackage\\|UIType\\|UsesObjectEquals\\|CFComment(.*)\\|Ensures.*\\|Requires.*\\|AnnotatedFor.*\\)")

;; Move annotations only on the HEAD method before the hunk.
(tags-query-replace
 ;; "\\|SuppressWarnings.*" intentionally omitted; it should be the last annotation and should be resolved by hand.
 (concat "^\\(<<<<<<< HEAD\n\\)\\(\\(" annotation-line-regex "\n\\)+\\)")
 "\\2\\1")

;; Move annotations only on the OTHER method before the hunk.
(tags-query-replace
 (concat "^\\(<<<<<<< HEAD\n[^|]*\n|||||||.*\n[^=]*=======\n\\)\\(\\(?:" annotation-line-regex "\n\\)+\\)")
 "\\2\\1")

;; Move Checker Framework imports before the hunk.
(tags-query-replace
 "^\\(<<<<<<< HEAD\n\\)\\(\\(import org.checkerframework..*;\n\\)+\n\\)"
 "\\2\\1")


;; Resolve the first line of a diff, when HEAD has been edited.
;; This version requires "public" at start of \2 and \4.
(tags-query-replace
 (concat
  "^\\(<<<<<<< HEAD\n\\)"
  "\\( *public .*\n\\)"
  "\\(\\(?:\\(?:[^|\n][^\n]*\\)?\n\\)*|||||||.*\n\\)"
  "\\( *public .*\n\\)"
  "\\(\\(?:\\(?:[^=\n][^\n]*\\)?\n\\)*=======\n\\)"
  "\\4")
 "\\2\\1\\3\\5")
;; The more general version, which I don't seem to need.
(tags-query-replace
 (concat
  "^\\(<<<<<<< HEAD\n\\)"
  "\\(.*\n\\)"
  "\\([^|]*\n|||||||.*\n\\)"
  "\\(.*\n\\)"
  "\\([^=]*\n=======\n\\)"
  "\\4")
 "\\2\\1\\3\\5")

;; Resolve the first line of a diff, when OTHER has been edited.
;; This version requires "public" at start of \2 and \4.
(tags-query-replace
 (concat
  "^\\(<<<<<<< HEAD\n\\)"
  "\\( *public .*\n\\)"
  "\\(\\(?:\\(?:[^|\n][^\n]*\\)?\n\\)*|||||||.*\n\\)"
  "\\2"
  "\\(\\(?:\\(?:[^=\n][^\n]*\\)?\n\\)*=======\n\\)"
  "\\( *public .*\n\\)")
 "\\5\\1\\3\\4")

;; Special case for the `equals()` method.
(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "    public boolean equals(Object obj) {\n"
  "||||||| [0-9a-f]\\{11\\}\n"
  "    public boolean equals(Object obj) {\n"
  "=======\n"
  "    public boolean equals(@Nullable Object obj) {\n"
  ">>>>>>> [0-9a-f]\\{40\\}\n")
 "    public boolean equals(@Nullable Object obj) {\n")

;; Resolve completely empty diffs.
(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "||||||| [0-9a-f]\\{11\\}\n"
  "=======\n"
  ">>>>>>> [0-9a-f]\\{40\\}\n")
 "")

;; Resolve diffs where one of the ancestors is empty.
(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "||||||| [0-9a-f]\\{11\\}\n"
  "=======\n"
  "\\([^~]*?\\)\n"
  ">>>>>>> [0-9a-f]\\{40\\}\n")
 "\\1")
(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "\\([^~]*?\n\\)"
  "||||||| [0-9a-f]\\{11\\}\n"
  "\\1"
  "=======\n"
  "\\([^~]*?\\)"
  ">>>>>>> [0-9a-f]\\{40\\}\n")
 "\\2")
