/* Portable real, continuous-time SISO rational models.
 * Coefficients are ascending powers of s, in rad/s. No cancellation, root
 * finding, coefficient rescaling, or realization inference happens here.
 * The caller must give exportTransfer the RAW transfer function when retaining
 * explicitly represented pole/zero factors matters.
 */
(function (root) {
  'use strict';
  const FORMAT = 'analog-studio-blackbox';
  const VERSION = 1;
  const LIMITS = Object.freeze({
    order: 12, coefficientMax: 1e100, coefficientMin: 1e-100,
    name: 120, description: 2000, source: 1000,
    warnings: 64, warning: 2000, warningTotal: 20000, json: 100000
  });
  const CAVEAT = '黑箱仅描述外部连续时间实系数 SISO 传递函数；即使保留未约分因子，也无法证明未知内部实现的稳定性，不能从稳定的外部响应推断内部稳定。';
  const IMPROPER = '非真有理黑箱的分子阶数高于分母，高频增益无界；阶跃可能含冲激或其导数，不能按普通时域曲线解释。';
  let serial = 0;
  const own = (value, key) => Object.prototype.hasOwnProperty.call(value, key);

  function fail(message) { throw new Error('黑箱模型：' + message); }
  function record(value, label, allowed) {
    if (!value || typeof value !== 'object' || Array.isArray(value)) fail(label + '必须是对象。');
    // Permit plain objects from other frames/VMs as well as null-prototype JSON
    // records; reject class instances and accessors rather than invoking them.
    const proto = Object.getPrototypeOf(value);
    if (proto !== null && Object.getPrototypeOf(proto) !== null) fail(label + '必须是普通 JSON 对象。');
    for (const key of Reflect.ownKeys(value)) {
      if (typeof key !== 'string' || !allowed.includes(key)) fail(label + '含不支持的字段：' + String(key) + '。');
      const descriptor = Object.getOwnPropertyDescriptor(value, key);
      if (!descriptor || !own(descriptor, 'value')) fail(label + '不允许访问器字段。');
    }
  }
  function required(value, key) {
    if (!own(value, key)) fail('缺少 ' + key + '。');
    return value[key];
  }
  function string(value, label, max, empty) {
    if (typeof value !== 'string') fail(label + '必须是字符串。');
    if (value.length > max || /[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/.test(value)) fail(label + '过长或包含控制字符。');
    const result = value.trim();
    if (!empty && !result) fail(label + '不能为空。');
    return result;
  }
  function coefficients(value, label) {
    if (!Array.isArray(value) || !value.length) fail(label + '必须是非空实数数组。');
    if (value.length > LIMITS.order + 1) fail(label + '最多支持 ' + LIMITS.order + ' 阶（13 个系数）。');
    // Index every entry: Array.map/some alone would silently accept sparse arrays.
    const result = [];
    for (let i = 0; i < value.length; i++) {
      const descriptor = Object.getOwnPropertyDescriptor(value, String(i));
      if (!descriptor || !own(descriptor, 'value')) fail(label + '不能含空缺或访问器。');
      const number = descriptor.value;
      if (typeof number !== 'number' || !Number.isFinite(number)) fail(label + '[' + i + '] 必须是有限实数，不能是字符串或复数。');
      const magnitude = Math.abs(number);
      if (magnitude > LIMITS.coefficientMax || (magnitude !== 0 && magnitude < LIMITS.coefficientMin)) fail(label + '[' + i + '] 的非零绝对值须在 10⁻¹⁰⁰ 至 10¹⁰⁰ 之间。');
      result.push(number === 0 ? 0 : number);
    }
    return result;
  }
  function warningList(value) {
    if (value === undefined) return [];
    if (!Array.isArray(value) || value.length > LIMITS.warnings) fail('warnings 必须是不超过 ' + LIMITS.warnings + ' 条的字符串数组。');
    const result = [], seen = new Set();
    let total = 0;
    for (let i = 0; i < value.length; i++) {
      const descriptor = Object.getOwnPropertyDescriptor(value, String(i));
      if (!descriptor || !own(descriptor, 'value')) fail('warnings 不能含空缺或访问器。');
      const warning = string(descriptor.value, '警告', LIMITS.warning, false);
      total += warning.length;
      if (total > LIMITS.warningTotal) fail('警告文本总长度超过限制。');
      if (!seen.has(warning)) { seen.add(warning); result.push(warning); }
    }
    return result;
  }
  function degree(array) {
    let result = array.length - 1;
    while (result > 0 && array[result] === 0) result--;
    return result;
  }
  function validate(input) {
    record(input, '模型', ['format', 'version', 'name', 'domain', 'ports', 'coefficientOrder', 'numerator', 'denominator', 'metadata', 'warnings']);
    if (required(input, 'format') !== FORMAT) fail('format 必须为 ' + FORMAT + '；频响采样（FRF）不能代替完整可计算模型。');
    if (required(input, 'version') !== VERSION) fail('仅支持 version: 1。');
    if (required(input, 'domain') !== 's') fail('仅支持连续时间 s 域；不支持 z 域或混合域模型。');
    if (required(input, 'coefficientOrder') !== 'ascending') fail('coefficientOrder 必须为 ascending（常数项在前）。');
    const ports = required(input, 'ports');
    record(ports, 'ports', ['inputs', 'outputs']);
    if (required(ports, 'inputs') !== 1 || required(ports, 'outputs') !== 1) fail('当前仅支持单输入、单输出（SISO）。');
    const numerator = coefficients(required(input, 'numerator'), 'numerator');
    const denominator = coefficients(required(input, 'denominator'), 'denominator');
    if (denominator.every(value => value === 0)) fail('denominator 不能是零多项式。');
    const model = {
      format: FORMAT, version: VERSION,
      name: string(required(input, 'name'), '名称', LIMITS.name, false),
      domain: 's', ports: { inputs: 1, outputs: 1 },
      coefficientOrder: 'ascending', numerator, denominator
    };
    if (own(input, 'metadata')) {
      record(input.metadata, 'metadata', ['description', 'source']);
      const metadata = {};
      if (own(input.metadata, 'description')) metadata.description = string(input.metadata.description, '说明', LIMITS.description, true);
      if (own(input.metadata, 'source')) metadata.source = string(input.metadata.source, '来源', LIMITS.source, true);
      model.metadata = metadata;
    }
    const warnings = warningList(own(input, 'warnings') ? input.warnings : undefined).filter(value => value !== CAVEAT && value !== IMPROPER);
    if (degree(numerator) > degree(denominator) && numerator.some(value => value !== 0)) warnings.push(IMPROPER);
    warnings.push(CAVEAT);
    // Reserve room for the generated warnings so validation remains idempotent.
    if (warnings.length > LIMITS.warnings || warnings.reduce((total, value) => total + value.length, 0) > LIMITS.warningTotal) fail('原始警告过多，无法完整保留模型限制说明。');
    model.warnings = warnings;
    return model;
  }
  function exportTransfer(tf, options) {
    record(tf, '原始传递函数', ['num', 'den', 'warnings', 'domain', 'coefficientOrder', 'ports']);
    if (own(tf, 'domain') && tf.domain !== 's') fail('不能把 z 域或混合域传递函数导出为 s 域模型。');
    if (own(tf, 'coefficientOrder') && tf.coefficientOrder !== 'ascending') fail('原始传递函数必须使用升幂系数。');
    if (own(tf, 'ports')) {
      record(tf.ports, 'ports', ['inputs', 'outputs']);
      if (required(tf.ports, 'inputs') !== 1 || required(tf.ports, 'outputs') !== 1) fail('原始传递函数必须是 SISO。');
    }
    if (typeof options === 'string') options = { name: options };
    if (options === undefined) options = {};
    record(options, '导出选项', ['name', 'description', 'source', 'metadata']);
    if (own(options, 'metadata') && (own(options, 'description') || own(options, 'source'))) fail('metadata 与 description/source 请只使用一种写法。');
    const model = {
      format: FORMAT, version: VERSION, name: own(options, 'name') ? options.name : '传递函数模型',
      domain: 's', ports: { inputs: 1, outputs: 1 }, coefficientOrder: 'ascending',
      numerator: required(tf, 'num'), denominator: required(tf, 'den'),
      warnings: own(tf, 'warnings') ? tf.warnings : []
    };
    if (own(options, 'metadata')) model.metadata = options.metadata;
    else if (own(options, 'description') || own(options, 'source')) {
      model.metadata = {};
      if (own(options, 'description')) model.metadata.description = options.description;
      if (own(options, 'source')) model.metadata.source = options.source;
    }
    return validate(model);
  }
  function makeNode(model) {
    const validated = validate(model);
    serial++;
    const suffix = root.crypto && typeof root.crypto.randomUUID === 'function' ? root.crypto.randomUUID() : Date.now().toString(36) + '-' + serial.toString(36);
    return { id: 'bb-' + suffix, kind: 'blackbox', weight: 1, model: validated };
  }
  function transfer(node) {
    if (!node || node.kind !== 'blackbox') fail('需要 kind: blackbox 节点。');
    const model = validate(node.model);
    // Branch weight belongs to AnalogCore's assembly, not this leaf transfer.
    return { num: model.numerator, den: model.denominator, warnings: model.warnings };
  }
  function parse(text) {
    if (typeof text !== 'string' || text.length > LIMITS.json) fail('JSON 必须是长度不超过 ' + LIMITS.json + ' 的文本。');
    let model;
    try { model = JSON.parse(text); } catch (_) { fail('JSON 语法无效。'); }
    return validate(model);
  }
  function stringify(model) { return JSON.stringify(validate(model), null, 2); }

  root.AnalogBlackbox = Object.freeze({ FORMAT, VERSION, LIMITS, CAVEAT, validate, exportTransfer, makeNode, transfer, parse, stringify });
})(typeof window !== 'undefined' ? window : globalThis);
