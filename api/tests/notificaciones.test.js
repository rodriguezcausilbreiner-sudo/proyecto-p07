import { test } from 'node:test';
import assert from 'node:assert/strict';
import { detectarAdelantamientos } from '../src/servicios/notificaciones.js';

test('sin tabla anterior no hay adelantamientos que notificar', () => {
  const nueva = [{ id: 1, nombre: 'Ficha A', total: 100, puesto: 1 }];
  assert.deepEqual(detectarAdelantamientos(null, nueva), []);
});

test('detecta cuando una ficha cae de puesto 1 a puesto 2', () => {
  const anterior = [
    { id: 1, nombre: 'Ficha A', total: 100, puesto: 1 },
    { id: 2, nombre: 'Ficha B', total: 90, puesto: 2 },
  ];
  const nueva = [
    { id: 2, nombre: 'Ficha B', total: 110, puesto: 1 },
    { id: 1, nombre: 'Ficha A', total: 100, puesto: 2 },
  ];
  const resultado = detectarAdelantamientos(anterior, nueva);
  assert.equal(resultado.length, 1);
  assert.equal(resultado[0].fichaId, 1);
  assert.equal(resultado[0].puestoAnterior, 1);
  assert.equal(resultado[0].puestoNuevo, 2);
});

test('no notifica a una ficha que mejora de puesto', () => {
  const anterior = [
    { id: 1, nombre: 'Ficha A', total: 100, puesto: 1 },
    { id: 2, nombre: 'Ficha B', total: 90, puesto: 2 },
  ];
  const nueva = [
    { id: 2, nombre: 'Ficha B', total: 110, puesto: 1 },
    { id: 1, nombre: 'Ficha A', total: 100, puesto: 2 },
  ];
  const resultado = detectarAdelantamientos(anterior, nueva);
  assert.equal(resultado.some((a) => a.fichaId === 2), false);
});

test('una ficha nueva en la tabla no genera adelantamiento (no tenía puesto previo)', () => {
  const anterior = [{ id: 1, nombre: 'Ficha A', total: 100, puesto: 1 }];
  const nueva = [
    { id: 1, nombre: 'Ficha A', total: 100, puesto: 2 },
    { id: 3, nombre: 'Ficha C', total: 150, puesto: 1 },
  ];
  const resultado = detectarAdelantamientos(anterior, nueva);
  assert.equal(resultado.length, 1);
  assert.equal(resultado[0].fichaId, 1);
});
