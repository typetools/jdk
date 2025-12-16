;; This file contains editor commands that are helpful when merging the JDK.

;; Run at the top level: etags $(rg --files-with-matches '<<<<<<')

;; To fix Java array declarations from
;; "short a2[]" to "short[] a2" or from
;; "@PolySigned short a2 @Nullable []" to "@PolySigned short @Nullable [] a2":
(tags-query-replace "\\([^@]\\)\\b\\([A-Z][a-z][A-Za-z0-9]+\\|byte\\|short\\|int\\|long\\|float\\|double\\|boolean\\|char\\) \\([A-Za-z0-9]+\\)\\(\\( ?@[A-Za-z0-9]+ ?\\)*\\[\\]\\)" "\\1\\2\\4 \\3")

;; Annotations only on the HEAD method.
(tags-query-replace
 ;; "\\|SuppressWarnings.*" intentionally omitted; it should be the last annotation and should be resolved by hand.
 "^\\(<<<<<<< HEAD\n\\)\\(\\( *@\\(CreatesMustCallFor\\|Deterministic\\|FormatMethod\\|PolyUIEffect\\|Pure\\|SideEffectFree\\|StaticallyExecutable\\|UIType\\|CFComment(.*)\\|Ensures.*\\|Requires.*\\|AnnotatedFor.*\\)\n\\)+\\)"
 "\\2\\1")

;; Annotations only on the OTHER method.
(tags-query-replace
 "^\\(<<<<<<< HEAD\n[^|]*\n|||||||.*\n[^=]*\n=======\n\\)\\(\\(?: *@\\(?:CallerSensitive\\|ForceInline\\|Override\\)\n\\)+\\)"
 "\\2\\1")

(tags-query-replace
 "^\\(<<<<<<< HEAD\n\\)\\(\\(import org.checkerframework..*;\n\\)+\n\\)"
 "\\2\\1")


;; Resolve the first line of a diff.
;; This version require "public" at start of \2 and \4.
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
