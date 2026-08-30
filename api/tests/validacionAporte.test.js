import { test } from 'node:test';
import assert from 'node:assert/strict';
import { esIncrementoValido } from '../src/servicios/validacionAporte.js';

test('acepta un incremento razonable (100 pasos en 10 minutos)', () => {
  assert.equal(esIncrementoValido({ pasos: 1000, segundosTranscurridos: 600 }), true);
});

test('rechaza un incremento imposible (5000 pasos en 1 minuto)', () => {
  assert.equal(esIncrementoValido({ pasos: 5000, segundosTranscurridos: 60 }), false);
});

test('acepta justo en el límite de 250 pasos/min', () => {
  assert.equal(esIncrementoValido({ pasos: 250, segundosTranscurridos: 60 }), true);
});

test('rechaza un pelo por encima del límite', () => {
  assert.equal(esIncrementoValido({ pasos: 251, segundosTranscurridos: 60 }), false);
});

test('rechaza pasos negativos', () => {
  assert.equal(esIncrementoValido({ pasos: -10, segundosTranscurridos: 60 }), false);
});

test('primer aporte del usuario (sin historial previo) tolera hasta 5 minutos de arranque', () => {
  assert.equal(esIncrementoValido({ pasos: 1200, segundosTranscurridos: 0 }), true);
  assert.equal(esIncrementoValido({ pasos: 2000, segundosTranscurridos: 0 }), false);
});
