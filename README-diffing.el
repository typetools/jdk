;; This file contains editor commands that are helpful when merging the JDK.

(delete-matching-lines "^\\+import org.checkerframework.*;$" nil nil t)b

(replace-string "\n \n+\n" "\n \n")

(delete-matching-lines (concat "^\\+" annotation-line-regex "$"))

(query-replace-regexp "@[A-Z][A-Za-z0-9_]* " "")
(query-replace-regexp "@[A-Z][A-Za-z0-9_]*([^()\n]*) " "")
(query-replace " []" "[]")
(query-replace " ..." "...")
(query-replace-regexp " \\([A-Za-z0-9_]*(\\)[A-Z][A-Za-z0-9_.]*\\(<[A-Z]\\(, ?[A-Z]\\)*>\\)? this, " " \\1")
(query-replace-regexp " \\([A-Za-z0-9_]*(\\)[A-Z][A-Za-z0-9_.]*\\(<[A-Z]\\(, ?[A-Z]\\)*>\\)? this)" " \\1)")
(query-replace-regexp " extends Object\\([,>]\\)" "\\1")
