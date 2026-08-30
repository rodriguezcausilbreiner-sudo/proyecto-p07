import prisma from '../prisma/cliente.js';
import { generarJwt } from '../servicios/auth.js';
import { loginDevSchema } from '../servicios/validacion.js';

/// Emite un token para un usuario y reto existentes. El banco de proyectos
/// ya resuelve el login completo con usuario/contraseña y rotación de
/// refresh token en P4 (Asistencia biométrica) — aquí se reutiliza esa
/// pieza en un proyecto real; este endpoint es un atajo documentado para
/// no duplicar esa lógica y poder centrarse en RF-01 a RF-06 de P7.
export async function emitirToken(req, res, next) {
  try {
    const { usuarioId, retoId } = loginDevSchema.parse(req.body);

    const usuario = await prisma.usuario.findUniqueOrThrow({ where: { id: usuarioId } });
    await prisma.reto.findUniqueOrThrow({ where: { id: retoId } });

    const token = generarJwt({ usuarioId: usuario.id, fichaId: usuario.fichaId, retoId });
    res.status(200).json({ token });
  } catch (err) {
    next(err);
  }
}
