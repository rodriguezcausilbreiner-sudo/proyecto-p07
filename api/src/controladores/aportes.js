import prisma from '../prisma/cliente.js';
import { aporteSchema } from '../servicios/validacion.js';
import { esIncrementoValido } from '../servicios/validacionAporte.js';
import { registrarAporte } from '../tiempo-real/tabla.js';

export async function crearAporte(req, res, next) {
  try {
    const retoId = req.params.retoId;
    const { usuarioId, pasos } = aporteSchema.parse(req.body);

    // El usuario autenticado solo puede reportar sus propios pasos.
    if (req.usuario.usuarioId !== usuarioId) {
      return res.status(403).json({ error: 'No puedes reportar pasos de otro usuario' });
    }

    const ultimoAporte = await prisma.aporte.findFirst({
      where: { usuarioId, retoId },
      orderBy: { creadoEn: 'desc' },
    });

    const segundosTranscurridos = ultimoAporte
      ? (Date.now() - ultimoAporte.creadoEn.getTime()) / 1000
      : 0;

    if (!esIncrementoValido({ pasos, segundosTranscurridos })) {
      return res.status(422).json({ error: 'Incremento de pasos no plausible (RF-06)' });
    }

    const tabla = await registrarAporte(usuarioId, retoId, pasos);
    res.status(201).json({ registrado: true, tabla });
  } catch (err) {
    next(err);
  }
}
