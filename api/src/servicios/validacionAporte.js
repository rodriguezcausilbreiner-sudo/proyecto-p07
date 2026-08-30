const MAX_PASOS_POR_MINUTO = Number(process.env.MAX_PASOS_POR_MINUTO ?? 250);

/// RF-06: descarta incrementos imposibles. 250 pasos/min es el techo
/// razonable de una persona corriendo; cualquier tasa mayor indica un
/// error de sincronización del contador (por ejemplo, sumar el
/// acumulado completo en vez del delta tras un reinicio mal manejado)
/// o un intento de manipular el resultado del reto.
///
/// Es lógica pura (sin Express, sin Prisma): se puede probar con
/// `node --test` sin levantar servidor ni base de datos.
export function esIncrementoValido({ pasos, segundosTranscurridos }) {
  if (pasos < 0) return false;
  if (segundosTranscurridos <= 0) {
    // Primer aporte del usuario en el reto: no hay tasa que calcular,
    // pero un primer aporte absurdamente alto también se rechaza.
    return pasos <= MAX_PASOS_POR_MINUTO * 5; // tolera hasta 5 min de arranque
  }
  const tasaPorMinuto = (pasos / segundosTranscurridos) * 60;
  const EPSILON = 1e-9; // evita falsos rechazos por redondeo de punto flotante en el límite exacto
  return tasaPorMinuto <= MAX_PASOS_POR_MINUTO + EPSILON;
}

export { MAX_PASOS_POR_MINUTO };
