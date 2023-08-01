# noir-mode
## Introduction
This package provides an Emacs major mode for editing [Noir](https://noir-lang.org/) code. It is derived from [`rust-mode`](https://github.com/rust-lang/rust-mode) and inherits the syntax highlighting mechanisms provided there with appropriate modifications. Mnemonic key bindings for running [`nargo`](https://noir-lang.org/getting_started/nargo/nargo_installation) commands in a compilation buffer are provided.
## Installation
### Straight.el
```
(straight-use-package
 '(noir-mode :type git :host github :repo "ax0/noir-mode"))
```
### Manual
Assuming this repository has been cloned to `/path/to/noir-mode` and `rust-mode` is installed, place the following in your `init.el` file:
```
(add-to-list 'load-path "/path/to/noir-mode")
(load "noir-mode")
```
## Key bindings
The following key bindings are meant to be mnemonic, being derived from either the command or its action:
Key binding           |   Command                    | Mnemonic (if applicable)
------------------------------|------------------------------|-------------
<kbd>C-c C-**n** C-**c**</kbd>| <code><b>n</b>argo-<b>c</b>heck</code>        |
<kbd>C-c C-**n** C-**s**</kbd>| <code><b>n</b>argo-codegen-verifier</code> | Generate **S**olidity verifier
<kbd>C-c C-**n** C-**b**</kbd>| <code><b>n</b>argo-compile</code>			 | **B**uild program
<kbd>C-c C-**n** C-**x**</kbd>| <code><b>n</b>argo-execute</code>			 | E**x**ecute program
<kbd>C-c C-**n** C-**i**</kbd>| <code><b>n</b>argo-<b>i</b>nfo</code>		 |
<kbd>C-c C-**n** C-**p**</kbd>| <code><b>n</b>argo-<b>p</b>rove</code>		|
<kbd>C-c C-**n** C-**t**</kbd>| <code><b>n</b>argo-<b>t</b>est</code>		 |
<kbd>C-c C-**n** C-**v**</kbd>| <code><b>n</b>argo-<b>v</b>erify</code>		 |

## Customisation group
The `noir-mode` customisation group is provided and contains the following user-customisable variables:

Variable | Description| Default value
---------|------------|----------
`nargo-allow-warnings` | Nargo flag for warning if unused variables are present| `nil`
`nargo-show-output` | Nargo flag for showing output of `println` statements | `nil`
`nargo-show-ssa` | Nargo flag for showing SSA IR | `nil`

These variables may be toggled in the usual manner via <kbd>M-x customize-group</kbd>.

## Quality of life improvements
### Colour output
`nargo` colours its output via ANSI escape sequences, which are not parsed by `compilation-mode` by default. Two solutions to this would be
- Using the following code:
	  ```
(require ansi-color)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
	  ```
- Installing the `fancy-compilation` package.
