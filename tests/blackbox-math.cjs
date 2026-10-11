'use strict';
// Pure VM schema tests and numeric reference tests. No DOM or dependencies.
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const dir = path.join(__dirname, '..');
const context = vm.createContext({ console });
vm.runInContext(fs.readFileSync(path.join(dir, 'blackbox-core.js'), 'utf8'), context);
const B = context.AnalogBlackbox;
const plain = value => JSON.parse(JSON.stringify(value));
const base = () => ({
  format: 'analog-studio-blackbox', version: 1, name: 'Reference low pass',
  domain: 's', ports: { inputs: 1, outputs: 1 }, coefficientOrder: 'ascending',
  numerator: [2], denominator: [1, 1]
});
let checks = 0;
function check(value, label) { assert(value, label); checks++; }
function near(actual, expected, tolerance = 2e-10) {
  assert(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`); checks++;
}
function rejects(mutate, pattern = /黑箱模型/) {
  const input = base(); mutate(input); assert.throws(() => B.validate(input), pattern); checks++;
}

// Deterministic schema, clone ownership, and JSON round trips.
const source = base(); source.name = '  Reference low pass  ';
source.metadata = { source: '  Lab prototype  ', description: '  Complete rational model  ' };
source.warnings = ['Original model limitation', 'Original model limitation'];
const before = plain(source), validated = B.validate(source);
assert.deepStrictEqual(source, before);
check(validated !== source && validated.numerator !== source.numerator && validated.denominator !== source.denominator);
check(validated.ports !== source.ports && validated.metadata !== source.metadata && validated.warnings !== source.warnings);
assert.deepStrictEqual(plain(B.validate(validated)), plain(validated));
assert.deepStrictEqual(plain(B.parse(B.stringify(validated))), plain(validated));
check(validated.name === 'Reference low pass');
check(validated.warnings.filter(value => value === 'Original model limitation').length === 1);
check(validated.warnings.includes(B.CAVEAT));
check(validated.metadata.description === 'Complete rational model');
const nullPrototype = Object.assign(Object.create(null), base());
check(B.validate(nullPrototype).name === nullPrototype.name);

// Coefficient order, scale, unreduced factors, padding, and warnings survive export.
const raw = { num: [-2, 2, 0], den: [-4, 2, 2, 0], warnings: ['Preserve this provenance'] };
const exported = B.exportTransfer(raw, { name: 'Unreduced', description: 's=+1 cancellation', source: 'Raw circuit transfer' });
assert.deepStrictEqual(plain(exported.numerator), raw.num);
assert.deepStrictEqual(plain(exported.denominator), raw.den);
check(exported.warnings.includes('Preserve this provenance'));
check(exported.warnings.includes(B.CAVEAT));
check(exported.metadata.source === 'Raw circuit transfer');
const nodes = Array.from({ length: 1000 }, () => B.makeNode(exported));
check(new Set(nodes.map(node => node.id)).size === nodes.length, 'Node IDs must be unique');
check(nodes.every(node => node.kind === 'blackbox' && node.weight === 1));
check(nodes[0].model !== exported && nodes[0].model.numerator !== exported.numerator);
const leaf = B.transfer(nodes[0]);
assert.deepStrictEqual(plain(leaf.num), raw.num);
assert.deepStrictEqual(plain(leaf.den), raw.den);
nodes[0].weight = -5;
assert.deepStrictEqual(plain(B.transfer(nodes[0])), plain(leaf), 'AnalogCore applies branch weight once');
leaf.num[0] = 888;
check(nodes[0].model.numerator[0] === -2, 'Transfer result must not alias the model');
check(B.exportTransfer({ num: [1], den: [1] }, 'Constant').name === 'Constant');
check(B.exportTransfer({ num: [1], den: [1] }).name.length > 0);
check(B.exportTransfer({ num: [1], den: [1] }, { metadata: { source: 'Custom' } }).metadata.source === 'Custom');
assert.throws(() => B.exportTransfer(raw, { metadata: {}, source: 'Conflicting' }));
assert.throws(() => B.transfer({ kind: 'block', model: base() }));
for (const unsupported of [{ domain: 'z' }, { domain: 'mixed' }, { coefficientOrder: 'descending' }, { ports: { inputs: 2, outputs: 1 } }, { frf: [] }, { delay: 1 }]) {
  assert.throws(() => B.exportTransfer({ num: [1], den: [1], ...unsupported }), /黑箱模型/); checks++;
}
check(B.exportTransfer({ num: [1], den: [1], domain: 's', coefficientOrder: 'ascending', ports: { inputs: 1, outputs: 1 } }).domain === 's');
const getterTF = { num: [1], den: [1] };
Object.defineProperty(getterTF, 'num', { get() { throw Error('Should not run'); } });
assert.throws(() => B.exportTransfer(getterTF), /访问器/);

// Supported degenerate cases remain valid mathematical models.
for (const [num, den] of [
  [[0], [1]], [[0, 0, 0], [-1, 1]], [[-3], [2]], [[0, 1], [1]],
  [[1, 0], [0, 1, 0]], [[1e100, 1e-100], [-1e100, 1e-100]],
  [[1], Array.from({ length: 13 }, (_, index) => index === 12 ? 1 : 0)]
]) {
  const model = B.exportTransfer({ num, den });
  assert.deepStrictEqual(plain(model.numerator), num);
  assert.deepStrictEqual(plain(model.denominator), den);
  assert.deepStrictEqual(plain(B.validate(model)), plain(model)); checks++;
}
check(B.exportTransfer({ num: [0, 1], den: [1] }).warnings.some(value => value.includes('非真有理')));
check(!B.exportTransfer({ num: [0, 0, 0], den: [1] }).warnings.some(value => value.includes('非真有理')));
check(!B.exportTransfer({ num: [1, 0, 0], den: [1] }).warnings.some(value => value.includes('非真有理')));
check(!Object.is(B.exportTransfer({ num: [-0], den: [1] }).numerator[0], -0));

// No inference from FRF points, unsupported domains, delayed/mixed models, or ports.
for (const key of ['format', 'version', 'name', 'domain', 'ports', 'coefficientOrder', 'numerator', 'denominator']) rejects(model => { delete model[key]; });
for (const value of [0, 2, '1', null]) rejects(model => { model.version = value; });
for (const value of ['z', ['s', 'z'], 'mixed', 'S', null]) rejects(model => { model.domain = value; });
for (const value of ['descending', 'ASCENDING', null]) rejects(model => { model.coefficientOrder = value; });
for (const value of [{ inputs: 2, outputs: 1 }, { inputs: 1, outputs: 2 }, { inputs: '1', outputs: 1 }, { inputs: 1 }, [1, 1]]) rejects(model => { model.ports = value; });
for (const key of ['frf', 'frequency', 'samples', 'sampleTime', 'delay', 'z', 'zeros', 'poles', 'gain', 'realization', '__proto__', 'constructor']) rejects(model => { Object.defineProperty(model, key, { value: [], enumerable: true }); });
rejects(model => { delete model.numerator; model.frf = [[1, 2, 0]]; });
rejects(model => { model.format = 'frequency-response'; });
rejects(model => { model.ports.extra = 1; });

// Nonfinite, malformed, excessive, tiny/huge, and string coefficients are rejected.
for (const value of [NaN, Infinity, -Infinity, 'NaN', 'Infinity', '1', null, true, {}, [], { re: 1, im: 0 }, 1e101, -1e101, 1e-101, -1e-101]) {
  rejects(model => { model.numerator = [value]; });
  rejects(model => { model.denominator = [value]; });
}
for (const key of ['numerator', 'denominator']) {
  for (const value of [[], null, '1, 2', { 0: 1, length: 1 }, new Array(2), Array(14).fill(1)]) rejects(model => { model[key] = value; });
}
rejects(model => { model.denominator = [0, -0, 0]; });
rejects(model => { model.numerator = [1]; Object.defineProperty(model.numerator, '0', { get() { throw Error('Should not run'); } }); });
rejects(model => { Object.defineProperty(model, 'numerator', { get() { throw Error('Should not run'); } }); });
rejects(model => { model.name = ' '; });
rejects(model => { model.name = 'x'.repeat(B.LIMITS.name + 1); });
rejects(model => { model.name = 'Hidden\u0000name'; });
rejects(model => { model.metadata = { description: 'x'.repeat(B.LIMITS.description + 1) }; });
rejects(model => { model.metadata = { source: 'x'.repeat(B.LIMITS.source + 1) }; });
rejects(model => { model.metadata = { unknown: 'silently ignored' }; });
rejects(model => { model.metadata = null; });
rejects(model => { model.warnings = [42]; });
rejects(model => { model.warnings = [null]; });
rejects(model => { model.warnings = new Array(1); });
rejects(model => { model.warnings = Array(B.LIMITS.warnings + 1).fill('Repeated'); });
rejects(model => { model.warnings = ['x'.repeat(B.LIMITS.warning + 1)]; });
rejects(model => { model.warnings = Array(20).fill('x'.repeat(1100)); });
rejects(model => { model.warnings = Array.from({ length: B.LIMITS.warnings }, (_, index) => 'Warning ' + index); });
assert.throws(() => B.parse('{"invalid": }'));
assert.throws(() => B.parse(' '.repeat(B.LIMITS.json + 1)));
assert.throws(() => B.parse(JSON.stringify({ ...base(), numerator: ['NaN'] })));
assert.throws(() => B.parse(JSON.stringify({ ...base(), numerator: [Infinity] })));

// Use the real numeric core, selecting its script by identity rather than index.
const html = fs.readFileSync(path.join(dir, 'AnalogStudio.html'), 'utf8');
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(match => match[1]);
const coreScript = scripts.find(script => script.includes('root.AnalogCore ='));
assert(coreScript, 'Built HTML must contain AnalogCore');
vm.runInContext(coreScript, context);
const C = context.AnalogCore;
function evaluateReference(tf, f) {
  const w = 2 * Math.PI * f;
  const polynomial = coefficients => {
    let re = 0, im = 0;
    for (let index = coefficients.length - 1; index >= 0; index--) [re, im] = [coefficients[index] - w * im, w * re];
    return { re, im };
  };
  const n = polynomial(tf.num), d = polynomial(tf.den), norm = d.re * d.re + d.im * d.im;
  return { re: (n.re * d.re + n.im * d.im) / norm, im: (n.im * d.re - n.re * d.im) / norm };
}
const fixtures = [
  { num: [2], den: [1, 1] }, { num: [-3], den: [2] },
  { num: [0, 1], den: [1] }, { num: [1], den: [0, 1] },
  { num: [-2, 2, 0], den: [-4, 2, 2, 0] },
  { num: [0, 0, 0], den: [-1, 1] }, { num: [1, 3, 2], den: [5, 1, 3] }
];
for (const fixture of fixtures) {
  const tf = B.transfer(B.makeNode(B.exportTransfer(fixture)));
  for (const f of [0.001, 0.01, 0.1, 1, 100, 1e5]) {
    const actual = C.evaluate(tf, f), expected = evaluateReference(fixture, f);
    near(actual.re, expected.re); near(actual.im, expected.im);
  }
}
const retained = B.transfer(B.makeNode(exported));
check(C.analyzeRaw(retained).stability === 'unstable', 'The explicitly retained s=+1 pole must survive');
check(C.analyze(retained).stability === 'stable', 'The reduced external transfer is stable');
check(retained.den.length === 4, 'Padded and unreduced polynomial must remain untouched');
for (const spec of C.catalog) {
  const rawTransfer = C.transferRaw(C.makeBlock(spec.type));
  const modelTransfer = B.transfer(B.makeNode(B.exportTransfer(rawTransfer, { name: spec.name, source: 'Catalog raw transfer' })));
  assert.deepStrictEqual(plain(modelTransfer.num), plain(rawTransfer.num));
  assert.deepStrictEqual(plain(modelTransfer.den), plain(rawTransfer.den));
  for (const f of [1, 1000, 1e6]) {
    const oldResponse = C.evaluate(rawTransfer, f), newResponse = C.evaluate(modelTransfer, f);
    near(newResponse.re, oldResponse.re); near(newResponse.im, oldResponse.im);
  }
}
console.log(`PASS blackbox math: ${checks} schema, clone, bounds, provenance, raw-factor, unique-node, and numeric-reference checks; all 11 catalog models retain their responses.`);
