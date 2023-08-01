;;; noir-mode.el --- Major mode for Aztec's Noir DSL  -*- lexical-binding: t; -*-

;; Author: Ahmad Afuni
;; Version: 0.1
;; Package-Requires: ((emacs "25.1") (rust-mode "1.0.5"))
;; Keywords: languages, noir
;; Url: https://github.com/ax0/noir-mode

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:
;; This package provides a major mode for Aztec's Noir ZK programming
;; language, which entails font locking, syntax highlighting and
;; convenient key bindings for calling Nargo, Noir's package
;; manager. It is derived from `rust-mode'.

;; The key bindings introduced are
;; * C-c C-n C-c - nargo-check
;; * C-c C-n C-s - nargo-codegen-verifier (`s' for `Solidity')
;; * C-c C-n C-b - nargo-compile (`b' for `build')
;; * C-c C-n C-x - nargo-execute (`x' for `eXecute')
;; * C-c C-n C-g - nargo-gates
;; * C-c C-n C-k - nargo-preprocess (`k' for `keys')
;; * C-c C-n C-a - nargo-print-acir
;; * C-c C-n C-p - nargo-prove
;; * C-c C-n C-t - nargo-test
;; * C-c C-n C-v - nargo-verify


;;; Code:

(require 'rust-mode)

;; Constants for font-locking purposes
(defconst noir-keywords
  '("as"
    "assert"
    "comptime"
    "contract"
    "distinct"
    "crate"
    "else" 
    "false"
    "fn"
    "for"
    "global"
    "if"
    "impl"
    "in"
    "let"
    "mod"
    "mut"
    "open"
    "pub"
    "self"
    "struct"
    "true"
    "unconstrained"
    "use")
  "Font-locking keywords.")

(defconst noir-special-types
  '("Field"
    "u1"
    "u2"
    "u3"
    "u4"
    "u8"
    "u16"
    "u32"
    "u64"
    "bool"
    "str")
  "Font-locking special types."
  )

(defconst noir-expression-introducers
  '("if" "constrain" "in")
  "List of Noir keywords that are always followed by expressions.")

;; Customisation group
(defgroup noir-mode nil "Noir-mode customisation group." :group 'languages)

(defcustom nargo-show-ssa nil "Nargo flag for showing SSA IR" :type 'boolean :group 'noir-mode)
(defcustom nargo-deny-warnings nil "Nargo flag for erroring out in case of warnings" :type 'boolean :group 'noir-mode)
(defcustom nargo-print-acir nil "Nargo flag for printing ACIR for the circuit" :type 'boolean :group 'noir-mode)
(defcustom nargo-show-output nil "Nargo flag for showing output of `println' statements" :type 'boolean :group 'noir-mode)

(defun nargo-opts ()
  (concat (if nargo-show-ssa "--show-ssa " "")
	  (if nargo-print-acir "--print-acir " "")
	  (if nargo-allow-warnings "--deny-warnings " "")))

(defun nargo-test-opts ()
  (concat (nargo-opts)
	  (if nargo-show-output "--show-output" "")))

;; Functions corresponding to Nargo commands
(defun nargo-cmd (cmd &optional arg)
  "Call a nargo command with an optional argument."
  (interactive "MCommand: \nMArgument: ")
  (defvar opts (if (equal cmd "test") (nargo-test-opts) (nargo-opts)))
  (compile (concat "nargo" " " cmd " " opts " " arg)))

(defun nargo-new (project-name)
  "Create a new Nargo project. The new project will be placed in
the current working directory."
  (interactive "MProject name: " )
  (funcall 'nargo-cmd "new" project-name))

(defun nargo-check ()
  "Check the constraint system of a Noir program for errors."
  (interactive)
  (funcall 'nargo-cmd "check"))

(defun nargo-codegen-verifier ()
  "Generate a Solidity verifier smart contract for a Noir program,
which will be placed under contract/."
  (interactive)
  (funcall 'nargo-cmd "codegen-verifier"))

(defun nargo-compile (circuit-name)
  "Compile a Noir program and its secret execution trace into ACIR
format, which will be placed under `target/.'"
  (interactive "MCircuit name: ")
  (funcall 'nargo-cmd "compile" circuit-name))

(defun nargo-execute (&optional witness-name)
  "Execute a Noir program's circuit to calculate its return value.
If WITNESS-NAME (which can be generated via nargo-compile) is specified,
then the execution trace will be placed in `target/WITNESS-NAME.tr'."
  (interactive "MWitness name: ")
  (funcall 'nargo-cmd "execute" witness-name))

(defun nargo-info ()
  "Count the occurrences of different gates in a Noir program's circuit."
  (interactive)
  (funcall 'nargo-cmd "info"))

(defun nargo-prove (&optional proof-name circuit-name)
  "Generate a proof for a Noir program in the form of a hex-encoded string.
If PROOF-NAME is specified, then the proof will be placed in
`proofs/PROOF-NAME.proof' rather than printed to stdout, and if CIRCUIT-NAME
is specified, then a proof for the compiled program under `target/' with this
name rather than the source code (if any) under `src/' will be generated."
  (interactive "MProof name (optional): \nMCircuit name (optional): ")
  (funcall 'nargo-cmd "prove" (concat proof-name circuit-name)))

(defun nargo-test (&optional test-name)
  "Run tests for a Noir program. If no argument is specified, all tests are run."
  (interactive "MTest name (optional): ")
  (funcall 'nargo-cmd "test" test-name))

(defun nargo-verify (proof-name &optional circuit-name)
  "Check the validity of a Noir program's proof, which should be found in
`proofs/PROOF-NAME.proof'. If CIRCUIT-NAME is specified, then this proof is
verified against the ACIR code and verification key under `target/' with this
name rather than the source code (if any) under `src/'."
  (interactive "MProof name: \nMCircuit name (optional): ")
  (funcall 'nargo-cmd "verify" (concat proof-name circuit-name)))

;; Key bindings for most of the above functions
(defvar noir-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-n C-c") 'nargo-check)
    (define-key map (kbd "C-c C-n C-s") 'nargo-codegen-verifier) ; 's' for Solidity
    (define-key map (kbd "C-c C-n C-b") 'nargo-compile) ; 'b' for build
    (define-key map (kbd "C-c C-n C-x") 'nargo-execute) ; 'x' for eXecute
    (define-key map (kbd "C-c C-n C-i") 'nargo-info)
    (define-key map (kbd "C-c C-n C-p") 'nargo-prove)
    (define-key map (kbd "C-c C-n C-t") 'nargo-test)
    (define-key map (kbd "C-c C-n C-v") 'nargo-verify)
    (set-keymap-parent map prog-mode-map)
    map)
  "Keymap for Noir major mode.")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.nr\\'" . noir-mode))

;;;###autoload
(define-derived-mode noir-mode
	rust-mode "Noir"
	"Major mode for editing Noir programs."
	(make-local-variable 'rust-expression-introducers) ; Avoid mode cross-contamination
	(setq rust-expression-introducers noir-expression-introducers)
	(font-lock-remove-keywords nil
				   `(
				     (,(regexp-opt rust-keywords 'symbols) . font-lock-keyword-face) ; Remove Rust keyword font locking
				     (,(regexp-opt rust-special-types 'symbols) . font-lock-type-face) ; Same for special types
				     ))
	(font-lock-add-keywords nil
				`(
				  (,(regexp-opt noir-keywords 'symbols) . font-lock-keyword-face) ; Add Noir keyword font locking
				  (,(regexp-opt noir-special-types 'symbols) . font-lock-type-face) ; Add Noir special types
				  (,(regexp-opt '("constrain") 'symbols) . font-lock-preprocessor-face) ; match `constrain` keyword
				  )))

(provide 'noir-mode)
;;; noir-mode.el ends here
