import { Router } from 'express';
import { emitirToken } from '../controladores/auth.js';
import { crearReto, obtenerTabla } from '../controladores/retos.js';
import { crearAporte } from '../controladores/aportes.js';
import { autenticar } from '../middlewares/autenticar.js';

const router = Router();

router.post('/auth/token', emitirToken);
router.post('/retos', crearReto);
router.get('/retos/:id/tabla', obtenerTabla);
router.post('/retos/:retoId/aportes', autenticar, crearAporte);

export default router;
