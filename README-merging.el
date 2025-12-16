;; This file contains editor commands that are helpful when merging the JDK.

;; Run at the top level: etags $(rg --files-with-matches '<<<<<<')

;; To fix Java array declarations from
;; "short a2[]" to "short[] a2" or from
;; "@PolySigned short a2 @Nullable []" to "@PolySigned short @Nullable [] a2":
(tags-query-replace "\\([^@]\\)\\b\\([A-Z][a-z][A-Za-z0-9]+\\|byte\\|short\\|int\\|long\\|float\\|double\\|boolean\\|char\\) \\([A-Za-z0-9]+\\)\\(\\( ?@[A-Za-z0-9]+ ?\\)*\\[\\]\\)" "\\1\\2\\4 \\3")

(defvar annotation-line-regex)
(setq annotation-line-regex
      " *@\\(CallerSensitive\\|ForceInline\\|Override\\|Covariant({[0-9]})\\|CreatesMustCallFor\\|Deterministic\\|EqualsMethod\\|ForName\\|FormatMethod\\|GetConstructor\\|GetClass\\|GetMethod\\|InheritableMustCall(.*)\\|I18nMakeFormat\\|Invoke\\|MayReleaseLocks\\|MustCall(.*)\\|NewInstance\\|NotOwning\\|OptionalCreator\\|OptionalEliminator\\|OptionalPropagator\\|PolyUIEffect\\|PolyUIType\\|Pure\\|ReleasesNoLocks\\|SafeEffect\\|SideEffectFree\\|SideEffectsOnly.*\\|StaticallyExecutable\\|TerminatesExecution\\|UIEffect\\|UIPackage\\|UIType\\|UsesObjectEquals\\|CFComment(.*)\\|Ensures.*\\|Requires.*\\|AnnotatedFor.*\\)")

;; Annotations only on the HEAD method.
(tags-query-replace
 ;; "\\|SuppressWarnings.*" intentionally omitted; it should be the last annotation and should be resolved by hand.
 (concat "^\\(<<<<<<< HEAD\n\\)\\(\\(" annotation-line-regex "\n\\)+\\)")
 "\\2\\1")

;; Annotations only on the OTHER method.
(tags-query-replace
 (concat "^\\(<<<<<<< HEAD\n[^|]*\n|||||||.*\n[^=]*=======\n\\)\\(\\(?:" annotation-line-regex "\n\\)+\\)")
 "\\2\\1")

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
;; The more general version.
(tags-query-replace
 "^\\(<<<<<<< HEAD\n\\)\\(.*\n\\)\\([^|]*\n|||||||.*\n\\)\\(.*\n\\)\\([^=]*\n=======\n\\)\\4"
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

(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "    public boolean equals(Object obj) {\n"
  "||||||| bb377b26730\n"
  "    public boolean equals(Object obj) {\n"
  "=======\n"
  "    public boolean equals(@Nullable Object obj) {\n"
  ">>>>>>> 79b055b580460e3d02ae44ca3e9bf1b6c6d0d581\n")
 "    public boolean equals(@Nullable Object obj) {\n")

(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "||||||| bb377b26730\n"
  "=======\n"
  ">>>>>>> 79b055b580460e3d02ae44ca3e9bf1b6c6d0d581\n")
 "")


;; Resolve trivial diffs
(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "||||||| 74007890bb9\n"
  "=======\n"
  "\\([^~]*?\\)\n"
  ">>>>>>> bb377b26730f3d9da7c76e0d171517e811cef3ce\n")
 "\\1")
(tags-query-replace
 (concat
  "<<<<<<< HEAD\n"
  "\\([^~]*?\n\\)"
  "||||||| 74007890bb9\n"
  "\\1"
  "=======\n"
  "\\([^~]*?\\)"
  ">>>>>>> bb377b26730f3d9da7c76e0d171517e811cef3ce\n")
 "\\2")
