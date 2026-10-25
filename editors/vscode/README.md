# Faz for VS Code

Language support for `.fz` files, plus the **Faz Blackberry** color theme.

## Install locally

This extension is not published to the Marketplace yet. From this directory, with Node.js 22+ and npm installed:

```sh
npm run package
code --install-extension faz-language-0.1.0.vsix
```

Packaging downloads the VS Code packaging tool through `npx`. You can also install the generated VSIX through **Extensions → … → Install from VSIX…**.

Reload VS Code, then open a `.fz` file. The language indicator should say **Faz**. If you previously associated `.fz` files with Python or plain text, remove that override from `files.associations` or change it to `"*.fz": "faz"`.

For a quick preview without installing or packaging, run from the repository root:

```sh
code --new-window --extensionDevelopmentPath="$PWD/editors/vscode" "$PWD"
```

## Choose the theme

Open **Preferences: Color Theme** in the Command Palette and select **Faz Blackberry**. Installing the extension does not change your current theme automatically; Faz highlighting works with other themes too.

| Role | Color |
| --- | --- |
| Background · dark plum | `#211827` |
| Text · cream | `#FFF4E5` |
| Keywords · raspberry | `#F28BA8` |
| Functions · lavender | `#C9A7EB` |
| Strings · sage | `#B6D7A8` |
| Numbers and booleans · honey | `#F2C779` |
| Types · sky | `#A4CBE8` |
| Comments · muted mauve | `#B7A3BE` |

The editor uses lighter versions of the brand colors for readability against the dark background. All syntax foreground colors meet a 4.5:1 contrast ratio against the editor background (checked by the tests).

## Included

- `.fz` file recognition and TextMate syntax highlighting for functions, records, enums, imports, matching, iteration, assertions, and built-in APIs.
- Four-space indentation, block indentation for declarations/control flow (including named return types and multiline function signatures), and indentation-based folding.
- `#` comment toggling, quote/parenthesis/bracket pairing. Expressions may continue inside parentheses and brackets.
- Snippets: `main`, `fn`, `fnvoid`, `print`, `ifelse`, `while`, `for`, `forrange`, `struct`, `enum`, `match`, `import`, `assert`, `list`, `strjoin`, `group`, and `httpserver`.
- Optional Blackberry theme, also usable with other languages.

This is a declarative extension: no executable extension code or runtime dependencies. It does **not** yet provide a language server, type-aware completion, compiler diagnostics, formatting, or debugging. Use `faz check file.fz` for diagnostics and `faz run file.fz` to run a program in the integrated terminal. Install the Faz CLI using the [repository README](../../README.md#try-it), then run `build/faz install "$HOME/.local"` and add `~/.local/bin` to your `PATH`. Faz owns its build, verification, installation, and test commands. LLVM supplies native code generation.

## Development

```sh
npm test
```

Tests validate contributed files, grammar patterns, indentation behavior, and palette contrast. Use an Extension Development Host to check actual VS Code rendering. The grammar targets [Faz syntax](../../examples), not Python syntax. TextMate scopes are lexical; the extension does not resolve imported symbols or infer user-defined types.
