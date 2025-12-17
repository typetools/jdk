;; Given a context diff between the Java JDK and the Checker Framework's
;; annotated JDK, run these commands to reduce the size of the diffs.  Most
;; remaining diffs indicate an unintentional edit that should be reverted in the
;; annotated JDK.

(progn
  (save-excursion
    (goto-char (point-min))

    (save-excursion
      (delete-matching-lines "^\\+import org.checkerframework.*;$" nil nil t))

    (save-excursion
      (replace-string "\n \n+\n" "\n \n"))

    (save-excursion
      (delete-matching-lines (concat "^\\+" annotation-line-regex "$")))

    (save-excursion
      (query-replace-regexp "@[A-Z][A-Za-z0-9_]* " ""))
    (save-excursion
      (query-replace-regexp "@[A-Z][A-Za-z0-9_]*([^()\n]*) " ""))
    (save-excursion
      (query-replace " []" "[]"))
    (save-excursion
      (query-replace " ..." "..."))
    (save-excursion
      (query-replace-regexp " \\([A-Za-z0-9_]*(\\)[A-Z][A-Za-z0-9_.]*\\(<[A-Z]\\(, ?[A-Z]\\)*>\\)? this, " " \\1"))
    (save-excursion
      (query-replace-regexp " \\([A-Za-z0-9_]*(\\)[A-Z][A-Za-z0-9_.]*\\(<[A-Z]\\(, ?[A-Z]\\)*>\\)? this)" " \\1)"))
    (save-excursion
      (query-replace-regexp " extends Object\\([,>]\\)" "\\1"))
    ))
