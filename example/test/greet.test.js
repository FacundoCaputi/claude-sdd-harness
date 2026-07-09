const { test } = require('node:test');
const assert = require('node:assert/strict');
const { greet } = require('../src/greet');

test('CA2 — greet("Ana") devuelve el saludo base', () => {
  assert.equal(greet('Ana'), 'Hola, Ana!');
});

test('CA3 — greeting custom via options', () => {
  assert.equal(greet('Ana', { greeting: 'Buenas' }), 'Buenas, Ana!');
});

test('CA4 — name ausente/vacío/blanco cae en "mundo"', () => {
  assert.equal(greet(''), 'Hola, mundo!');
  assert.equal(greet('   '), 'Hola, mundo!');
  assert.equal(greet(undefined), 'Hola, mundo!');
  assert.equal(greet(null), 'Hola, mundo!');
});

test('CA5 — trim del name', () => {
  assert.equal(greet('  Ana  '), 'Hola, Ana!');
});

test('CA6 — trim del greeting', () => {
  assert.equal(greet('mundo', { greeting: '  Buenas  ' }), 'Buenas, mundo!');
});

test('CA7 — determinismo: misma entrada, misma salida', () => {
  assert.equal(
    greet('Ana', { greeting: 'Buenas' }),
    greet('Ana', { greeting: 'Buenas' }),
  );
});
