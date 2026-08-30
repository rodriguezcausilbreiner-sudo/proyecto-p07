import prisma from '../prisma/cliente.js';
import { verificarJwt } from '../servicios/auth.js';
import { notificarAdelantamientos } from '../servicios/notificaciones.js';

// Cache en memoria de la última tabla calculada por reto, para poder
// enviarla de inmediato a quien se conecta sin esperar el próximo aporte.
const cacheTabla = new Map();

let ioGlobal;

export function montarTiempoReal(io) {
  ioGlobal = io;

  // Autenticación del socket: sin token válido no hay conexión.
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token;
      socket.usuario = verificarJwt(token);
      next();
    } catch {
      next(new Error('no autorizado'));
    }
  });

  io.on('connection', (socket) => {
    const retoId = socket.usuario.retoId;
    // Cada reto tiene su sala: solo recibe lo que le concierne.
    socket.join(`reto:${retoId}`);
    const tablaActual = cacheTabla.get(retoId);
    if (tablaActual) socket.emit('tabla:actual', tablaActual);
  });
}

export async function registrarAporte(usuarioId, retoId, pasos) {
  await prisma.aporte.create({ data: { usuarioId, retoId, pasos } });

  const tabla = await prisma.$queryRaw`
    SELECT f.id, f.nombre, SUM(a.pasos)::int AS total,
           RANK() OVER (ORDER BY SUM(a.pasos) DESC) AS puesto
    FROM aporte a
    JOIN usuario u ON u.id = a.usuario_id
    JOIN ficha f ON f.id = u.ficha_id
    WHERE a.reto_id = ${retoId}::uuid
    GROUP BY f.id, f.nombre
    ORDER BY total DESC`;

  const tablaSerializable = tabla.map((f) => ({ ...f, total: Number(f.total), puesto: Number(f.puesto) }));
  const tablaAnterior = cacheTabla.get(retoId);
  cacheTabla.set(retoId, tablaSerializable);

  if (ioGlobal) {
    ioGlobal.to(`reto:${retoId}`).emit('tabla:actual', tablaSerializable);
  }

  await notificarAdelantamientos(retoId, tablaAnterior, tablaSerializable);
  return tablaSerializable;
}

export function obtenerTablaCache(retoId) {
  return cacheTabla.get(retoId) ?? [];
}
