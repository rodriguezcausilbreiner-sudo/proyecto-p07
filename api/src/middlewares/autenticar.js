import { verificarJwt } from '../servicios/auth.js';

export function autenticar(req, res, next) {
  const encabezado = req.headers.authorization;
  if (!encabezado?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Falta el token de autorización' });
  }
  try {
    req.usuario = verificarJwt(encabezado.slice(7));
    next();
  } catch {
    res.status(401).json({ error: 'Token inválido o expirado' });
  }
}
