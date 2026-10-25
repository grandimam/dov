const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.join(__dirname, '..');
const read = file => JSON.parse(fs.readFileSync(path.join(root, file), 'utf8'));
const manifest = read('package.json');
const grammar = read('syntaxes/faz.tmLanguage.json');
const config = read('language-configuration.json');
const theme = read('themes/blackberry-color-theme.json');

function walk(value, visit) {
  if (value && typeof value === 'object') {
    visit(value);
    for (const child of Object.values(value)) walk(child, visit);
  }
}

test('all contributions resolve and Faz owns .fz files', () => {
  assert.deepEqual(manifest.contributes.languages[0].extensions, ['.fz']);
  assert.equal(manifest.contributes.grammars[0].scopeName, grammar.scopeName);
  assert.equal(grammar.scopeName, 'source.faz');
  for (const item of [
    ...manifest.contributes.grammars, ...manifest.contributes.snippets, ...manifest.contributes.themes,
  ]) assert.ok(read(item.path));
  assert.ok(read(manifest.contributes.languages[0].configuration));
  assert.ok(fs.existsSync(path.join(root, 'LICENSE')));
  assert.equal(manifest.contributes.languages[0].id, 'faz');
  assert.equal(manifest.name, 'faz-language');
  assert.ok(fs.existsSync(path.join(root, manifest.icon)));
  assert.equal(fs.readFileSync(path.join(root, manifest.icon)).subarray(1, 4).toString(), 'PNG');
});

test('grammar regexes compile and local includes resolve', () => {
  walk(grammar, node => {
    for (const key of ['match', 'begin', 'end']) {
      if (node[key]) assert.doesNotThrow(() => new RegExp(node[key]));
    }
    if (node.include?.startsWith('#')) assert.ok(grammar.repository[node.include.slice(1)]);
  });
});

test('functions, keywords, calls, and supported escapes have scopes', () => {
  const fn = grammar.patterns.find(p => p.captures);
  const match = new RegExp(fn.match).exec('fn greet(name: str):');
  assert.equal(match[1], 'fn');
  assert.equal(match[2], 'greet');
  const pattern = name => new RegExp(grammar.patterns.find(p => p.name === name).match);
  assert.ok(pattern('keyword.control.faz').test('return'));
  for (const word of ['with', 'for', 'in', 'match', 'case', 'assert', 'import']) {
    assert.ok(pattern('keyword.control.faz').test(word), word);
    assert.ok(!pattern('keyword.control.faz').test(`${word}_name`), word);
  }
  assert.ok(pattern('support.function.builtin.faz').test('task.sleep('));
  for (const name of ['len', 'str', 'str.join', 'range', 'fs.read_text', 'fs.write_text', 'fs.canonical', 'fs.exists', 'sys.args']) {
    assert.ok(pattern('support.function.builtin.faz').test(`${name}(`), name);
    assert.ok(!pattern('support.function.builtin.faz').test(`${name}_custom(`), name);
  }
  for (const call of ['str(42)', 'str.join(parts, ",")', 'fs.canonical(path)', 'fs.exists(path)']) {
    const firstMatch = grammar.patterns.find(p => p.match && new RegExp(p.match).test(call));
    assert.equal(firstMatch.name, 'support.function.builtin.faz', call);
  }
  const declaration = grammar.patterns.find(p => p.captures?.['2']?.name === 'entity.name.type.faz');
  for (const line of ['struct Token:', 'enum Expr:']) {
    const match = new RegExp(declaration.match).exec(line);
    assert.ok(match, line);
    assert.ok(['Token', 'Expr'].includes(match[2]));
  }
  assert.ok(pattern('support.type.faz').test('list'));
  assert.ok(pattern('support.function.builtin.faz').test('http.serve('));
  assert.ok(!pattern('keyword.control.faz').test('returning'));
  assert.ok(pattern('support.function.builtin.faz').test('print('));
  assert.ok(pattern('invalid.illegal.keyword.faz').test('def'));
  const escape = new RegExp(grammar.repository.escapes.patterns[0].match);
  assert.ok(escape.test('\\n'));
  assert.ok(escape.test('\\"'));
  assert.ok(!escape.test('\\q'));
});

test('indentation targets blocks, not strings or comments', () => {
  const increase = new RegExp(config.indentationRules.increaseIndentPattern);
  for (const line of ['fn main():', 'fn add(a: int) -> int: # hi', '    if x == 1:', 'elif ready:', 'else:', 'while True:', 'with task.group() as group:', 'fn lex(source: str) -> list[str]:', 'fn nested() -> list[list[int]]:', 'fn parse() -> syntax.Expr:', 'fn scan() -> list[syntax.Token]:', 'struct Token:', 'enum Expr:', 'match expression:', 'case Expr.Number(value):', 'case _:', 'for item in items:', 'for i in range(10):', ') -> syntax.Expr:', '):']) {
    assert.ok(increase.test(line), line);
  }
  for (const line of ['# if True:', 'print("label:")', 'name = "fn main():"', 'x: int = 1', 'value: syntax.Expr', 'import syntax', '# struct Fake:', 'text = "case _:"']) {
    assert.ok(!increase.test(line), line);
  }
  assert.equal(config.folding.offSide, true);
  assert.equal(manifest.contributes.configurationDefaults['[faz]']['editor.tabSize'], 4);
});

function luminance(hex) {
  const rgb = hex.slice(1).match(/../g).map(v => parseInt(v, 16) / 255)
    .map(v => v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4);
  return rgb[0] * 0.2126 + rgb[1] * 0.7152 + rgb[2] * 0.0722;
}

test('syntax foregrounds have readable contrast against the editor', () => {
  const bg = luminance(theme.colors['editor.background']);
  for (const rule of theme.tokenColors) {
    const fg = luminance(rule.settings.foreground);
    const ratio = (Math.max(fg, bg) + 0.05) / (Math.min(fg, bg) + 0.05);
    assert.ok(ratio >= 4.5, `${rule.name}: ${ratio.toFixed(2)}:1`);
  }
});


test('foundation snippets cover declarations, iteration, matching, and builtins', () => {
  const snippets = read('snippets/faz.json');
  const prefixes = Object.values(snippets).map(snippet => snippet.prefix);
  for (const prefix of ['struct', 'enum', 'match', 'for', 'forrange', 'import', 'assert', 'list', 'group', 'httpserver', 'strjoin']) {
    assert.ok(prefixes.includes(prefix), prefix);
  }
  assert.equal(new Set(prefixes).size, prefixes.length);
  for (const snippet of Object.values(snippets)) {
    assert.ok(Array.isArray(snippet.body) && snippet.body.length > 0);
    assert.ok(snippet.body.every(line => !line.includes('\t')));
  }
});
