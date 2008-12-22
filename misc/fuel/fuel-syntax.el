;;; fuel-syntax.el --- auxiliar definitions for factor code navigation.

;; Copyright (C) 2008  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;; Auxiliar constants and functions to parse factor code.

;;; Code:

(require 'thingatpt)


;;; Thing-at-point support for factor symbols:

(defun fuel-syntax--beginning-of-symbol ()
  "Move point to the beginning of the current symbol."
  (skip-syntax-backward "w_()"))

(defsubst fuel-syntax--beginning-of-symbol-pos ()
  (save-excursion (fuel-syntax--beginning-of-symbol) (point)))

(defun fuel-syntax--end-of-symbol ()
  "Move point to the end of the current symbol."
  (skip-syntax-forward "w_()"))

(defsubst fuel-syntax--end-of-symbol-pos ()
  (save-excursion (fuel-syntax--end-of-symbol) (point)))

(put 'factor-symbol 'end-op 'fuel-syntax--end-of-symbol)
(put 'factor-symbol 'beginning-op 'fuel-syntax--beginning-of-symbol)

(defsubst fuel-syntax-symbol-at-point ()
  (let ((s (substring-no-properties (thing-at-point 'factor-symbol))))
    (and (> (length s) 0) s)))



;;; Regexps galore:

(defconst fuel-syntax--parsing-words
  '("{" "}" "^:" "^::" ";" "<<" "<PRIVATE" ">>"
    "BIN:" "BV{" "B{" "C:" "C-STRUCT:" "C-UNION:" "CHAR:" "CS{" "C{"
    "DEFER:" "ERROR:" "EXCLUDE:" "FORGET:"
    "GENERIC#" "GENERIC:" "HEX:" "HOOK:" "H{"
    "IN:" "INSTANCE:" "INTERSECTION:"
    "M:" "MACRO:" "MACRO::" "MAIN:" "MATH:" "MEMO:" "METHOD:" "MIXIN:"
    "OCT:" "POSTPONE:" "PREDICATE:" "PRIMITIVE:" "PRIVATE>" "PROVIDE:"
    "REQUIRE:"  "REQUIRES:" "SINGLETON:" "SLOT:" "SYMBOL:" "SYMBOLS:"
    "TUPLE:" "T{" "t\\??" "TYPEDEF:"
    "UNION:" "USE:" "USING:" "V{" "VARS:" "W{"))

(defconst fuel-syntax--parsing-words-ext-regex
  (regexp-opt '("B" "call-next-method" "delimiter" "f" "initial:" "read-only")
              'words))

(defconst fuel-syntax--declaration-words
  '("flushable" "foldable" "inline" "parsing" "recursive"))

(defconst fuel-syntax--declaration-words-regex
  (regexp-opt fuel-syntax--declaration-words 'words))

(defsubst fuel-syntax--second-word-regex (prefixes)
  (format "^%s +\\([^ \r\n]+\\)" (regexp-opt prefixes t)))

(defconst fuel-syntax--method-definition-regex
  "^M: +\\([^ ]+\\) +\\([^ ]+\\)")

(defconst fuel-syntax--word-definition-regex
  (fuel-syntax--second-word-regex '(":" "::" "GENERIC:")))

(defconst fuel-syntax--type-definition-regex
  (fuel-syntax--second-word-regex '("TUPLE:" "SINGLETON:")))

(defconst fuel-syntax--parent-type-regex "^TUPLE: +[^ ]+ +< +\\([^ ]+\\)")

(defconst fuel-syntax--constructor-regex "<[^ >]+>")

(defconst fuel-syntax--getter-regex "\\(^\\|\\_<\\)[^ ]+?>>\\_>")
(defconst fuel-syntax--setter-regex "\\_<>>.+?\\_>")

(defconst fuel-syntax--symbol-definition-regex
  (fuel-syntax--second-word-regex '("SYMBOL:" "VAR:")))

(defconst fuel-syntax--stack-effect-regex " ( .* )")

(defconst fuel-syntax--using-lines-regex "^USING: +\\([^;]+\\);")

(defconst fuel-syntax--use-line-regex "^USE: +\\(.*\\)$")

(defconst fuel-syntax--current-vocab-regex "^IN: +\\([^ \r\n\f]+\\)")

(defconst fuel-syntax--sub-vocab-regex "^<\\([^ \n]+\\) *$")

(defconst fuel-syntax--definition-starters-regex
  (regexp-opt '("VARS" "TUPLE" "MACRO" "MACRO:" "M" "MEMO" "METHOD" ":" "")))

(defconst fuel-syntax--definition-start-regex
  (format "^\\(%s:\\) " fuel-syntax--definition-starters-regex))

(defconst fuel-syntax--definition-end-regex
  (format "\\(\\(^\\| +\\);\\( *%s\\)*\\($\\| +\\)\\)"
          fuel-syntax--declaration-words-regex))

(defconst fuel-syntax--single-liner-regex
  (format "^%s" (regexp-opt '("C:" "DEFER:" "GENERIC:" "IN:"
                              "PRIVATE>" "<PRIVATE"
                              "SINGLETON:" "SYMBOL:" "USE:" "VAR:"))))

(defconst fuel-syntax--begin-of-def-regex
  (format "^USING: \\|\\(%s\\)\\|\\(%s .*\\)"
          fuel-syntax--definition-start-regex
          fuel-syntax--single-liner-regex))

(defconst fuel-syntax--end-of-def-line-regex
  (format "^.*%s" fuel-syntax--definition-end-regex))

(defconst fuel-syntax--end-of-def-regex
  (format "\\(%s\\)\\|\\(%s .*\\)"
          fuel-syntax--end-of-def-line-regex
          fuel-syntax--single-liner-regex))

(defconst fuel-syntax--defun-signature-regex
  (format "\\(%s\\|%s\\)"
          (format ":[^ ]* [^ ]+\\(%s\\)*" fuel-syntax--stack-effect-regex)
          "M[^:]*: [^ ]+ [^ ]+"))


;;; Factor syntax table

(defvar fuel-syntax--syntax-table
  (let ((table (make-syntax-table)))
    ;; Default is word constituent
    (dotimes (i 256)
      (modify-syntax-entry i "w" table))

    ;; Whitespace
    (modify-syntax-entry ?\t " " table)
    (modify-syntax-entry ?\f " " table)
    (modify-syntax-entry ?\r " " table)
    (modify-syntax-entry ?\  " " table)
    (modify-syntax-entry ?\n " " table)

    ;; Parenthesis
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)
    (modify-syntax-entry ?{ "(}" table)
    (modify-syntax-entry ?} "){" table)

    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)

    ;; Strings
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "/" table)
    table))

(defconst fuel-syntax--syntactic-keywords
  `(("\\(#!\\) .*\\(\n\\)" (1 "<") (2 ">"))
    ("\\( \\|^\\)\\(!\\) .*\\(\n\\)" (2 "<") (3 ">"))
    ("\\(!(\\) .* \\()\\)" (1 "<") (2 ">"))
    ("\\(\\[\\)\\(let\\|wlet\\|let\\*\\)\\( \\|$\\)" (1 "(]"))
    ("\\(\\[\\)\\(|\\) +[^|]* \\(|\\)" (1 "(]") (2 "(|") (3 ")|"))
    (" \\(|\\) " (1 "(|"))
    (" \\(|\\)$" (1 ")"))
    ("\\([[({]\\)\\([^ \"\n]\\)" (1 "_") (2 "_"))
    ("\\([^ \"\n]\\)\\([])}]\\)" (1 "_") (2 "_"))))


;;; Source code analysis:

(defsubst fuel-syntax--brackets-depth ()
  (nth 0 (syntax-ppss)))

(defsubst fuel-syntax--brackets-start ()
  (nth 1 (syntax-ppss)))

(defun fuel-syntax--brackets-end ()
  (save-excursion
    (goto-char (fuel-syntax--brackets-start))
    (condition-case nil
        (progn (forward-sexp)
               (1- (point)))
      (error -1))))

(defsubst fuel-syntax--indentation-at (pos)
  (save-excursion (goto-char pos) (current-indentation)))

(defsubst fuel-syntax--increased-indentation (&optional i)
  (+ (or i (current-indentation)) factor-indent-width))
(defsubst fuel-syntax--decreased-indentation (&optional i)
  (- (or i (current-indentation)) factor-indent-width))

(defsubst fuel-syntax--at-begin-of-def ()
  (looking-at fuel-syntax--begin-of-def-regex))

(defsubst fuel-syntax--at-end-of-def ()
  (looking-at fuel-syntax--end-of-def-regex))

(defsubst fuel-syntax--looking-at-emptiness ()
  (looking-at "^[ ]*$\\|$"))

(defsubst fuel-syntax--is-eol (pos)
  (save-excursion
    (goto-char (1+ pos))
    (fuel-syntax--looking-at-emptiness)))

(defsubst fuel-syntax--line-offset (pos)
  (- pos (save-excursion
           (goto-char pos)
           (beginning-of-line)
           (point))))

(defun fuel-syntax--previous-non-blank ()
  (forward-line -1)
  (while (and (not (bobp)) (fuel-syntax--looking-at-emptiness))
    (forward-line -1)))

(defun fuel-syntax--beginning-of-block-pos ()
  (save-excursion
    (if (> (fuel-syntax--brackets-depth) 0)
        (fuel-syntax--brackets-start)
      (fuel-syntax--beginning-of-defun)
      (point))))

(defun fuel-syntax--at-setter-line ()
  (save-excursion
    (beginning-of-line)
    (when (re-search-forward fuel-syntax--setter-regex
                             (line-end-position)
                             t)
      (let* ((to (match-beginning 0))
             (from (fuel-syntax--beginning-of-block-pos)))
        (goto-char from)
        (let ((depth (fuel-syntax--brackets-depth)))
          (and (or (re-search-forward fuel-syntax--constructor-regex to t)
                   (re-search-forward fuel-syntax--setter-regex to t))
               (= depth (fuel-syntax--brackets-depth))))))))

(defun fuel-syntax--at-constructor-line ()
  (save-excursion
    (beginning-of-line)
    (re-search-forward fuel-syntax--constructor-regex (line-end-position) t)))

(defsubst fuel-syntax--at-using ()
  (looking-at fuel-syntax--using-lines-regex))

(defun fuel-syntax--in-using ()
  (let ((p (point)))
    (save-excursion
      (and (re-search-backward "^USING: " nil t)
           (re-search-forward " ;" nil t)
           (< p (match-end 0))))))

(defsubst fuel-syntax--beginning-of-defun (&optional times)
  (re-search-backward fuel-syntax--begin-of-def-regex nil t times))

(defsubst fuel-syntax--end-of-defun ()
  (re-search-forward fuel-syntax--end-of-def-regex nil t))

(defsubst fuel-syntax--end-of-defun-pos ()
  (save-excursion
    (re-search-forward fuel-syntax--end-of-def-regex nil t)
    (point)))

(defun fuel-syntax--beginning-of-body ()
  (let ((p (point)))
    (and (fuel-syntax--beginning-of-defun)
         (re-search-forward fuel-syntax--defun-signature-regex p t)
         (not (re-search-forward fuel-syntax--end-of-def-regex p t)))))

(defun fuel-syntax--beginning-of-sexp ()
  (if (> (fuel-syntax--brackets-depth) 0)
      (goto-char (fuel-syntax--brackets-start))
    (fuel-syntax--beginning-of-body)))

(defsubst fuel-syntax--beginning-of-sexp-pos ()
  (save-excursion (fuel-syntax--beginning-of-sexp) (point)))


;;; USING/IN:

(make-variable-buffer-local
 (defvar fuel-syntax--current-vocab-function 'fuel-syntax--find-in))

(defsubst fuel-syntax--current-vocab ()
  (funcall fuel-syntax--current-vocab-function))

(defun fuel-syntax--find-in ()
  (let* ((vocab)
         (ip
          (save-excursion
            (when (re-search-backward fuel-syntax--current-vocab-regex nil t)
              (setq vocab (match-string-no-properties 1))
              (point)))))
    (when ip
      (let ((pp (save-excursion
                  (when (re-search-backward fuel-syntax--sub-vocab-regex ip t)
                    (point)))))
        (when (and pp (> pp ip))
          (let ((sub (match-string-no-properties 1)))
            (unless (save-excursion (search-backward (format "%s>" sub) pp t))
              (setq vocab (format "%s.%s" vocab (downcase sub))))))))
    vocab))

(make-variable-buffer-local
 (defvar fuel-syntax--usings-function 'fuel-syntax--find-usings))

(defsubst fuel-syntax--usings ()
  (funcall fuel-syntax--usings-function))

(defun fuel-syntax--find-usings ()
  (save-excursion
    (let ((usings)
          (in (fuel-syntax--current-vocab)))
      (when in (setq usings (list in)))
      (goto-char (point-max))
      (while (re-search-backward fuel-syntax--using-lines-regex nil t)
        (dolist (u (split-string (match-string-no-properties 1) nil t))
          (push u usings)))
      usings)))


(provide 'fuel-syntax)
;;; fuel-syntax.el ends here
