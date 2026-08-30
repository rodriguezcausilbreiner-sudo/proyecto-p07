import { z } from 'zod';

export const loginDevSchema = z.object({
  usuarioId: z.coerce.number().int().positive(),
  retoId: z.string().uuid(),
});

export const aporteSchema = z.object({
  usuarioId: z.coerce.number().int().positive(),
  pasos: z.coerce.number().int().min(0),
});
