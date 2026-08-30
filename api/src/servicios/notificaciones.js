/// Compara la tabla anterior con la nueva y devuelve la lista de fichas
/// que fueron superadas (su puesto empeoró). Es lógica pura -sin FCM, sin
/// red- para poder probarla sin mockear un servicio externo.
export function detectarAdelantamientos(tablaAnterior, tablaNueva) {
  if (!tablaAnterior || tablaAnterior.length === 0) return [];

  const puestoAnteriorPorFicha = new Map(tablaAnterior.map((f) => [f.id, f.puesto]));
  const adelantamientos = [];

  for (const fichaNueva of tablaNueva) {
    const puestoAnterior = puestoAnteriorPorFicha.get(fichaNueva.id);
    if (puestoAnterior !== undefined && fichaNueva.puesto > puestoAnterior) {
      adelantamientos.push({ fichaId: fichaNueva.id, nombre: fichaNueva.nombre, puestoAnterior, puestoNuevo: fichaNueva.puesto });
    }
  }

  return adelantamientos;
}

/// Punto de integración con Firebase Cloud Messaging. Se deja como stub
/// documentado: el envío real requiere las credenciales del proyecto
/// Firebase del centro, que no forman parte de este banco de proyectos.
export async function notificarAdelantamientos(retoId, tablaAnterior, tablaNueva) {
  const adelantamientos = detectarAdelantamientos(tablaAnterior, tablaNueva);
  for (const a of adelantamientos) {
    // TODO integración real: admin.messaging().sendToTopic(`reto_${retoId}_ficha_${a.fichaId}`, {...})
    console.log(`[push] Ficha "${a.nombre}" fue superada: puesto ${a.puestoAnterior} -> ${a.puestoNuevo}`);
  }
  return adelantamientos;
}
