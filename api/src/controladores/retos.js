import prisma from '../prisma/cliente.js';
import { obtenerTablaCache } from '../tiempo-real/tabla.js';

export async function crearReto(req, res, next) {
  try {
    const { nombre, iniciaEn, terminaEn } = req.body;
    const reto = await prisma.reto.create({
      data: { nombre, iniciaEn: new Date(iniciaEn), terminaEn: new Date(terminaEn) },
    });
    res.status(201).json(reto);
  } catch (err) {
    next(err);
  }
}

export async function obtenerTabla(req, res, next) {
  try {
    const tabla = obtenerTablaCache(req.params.id);
    res.status(200).json({ tabla });
  } catch (err) {
    next(err);
  }
}
