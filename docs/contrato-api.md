# Contrato de API · P7 Reto de pasos entre fichas

Base URL local: `http://localhost:3000/api`. WebSocket en la raíz del
mismo servidor (`http://localhost:3000`, namespace por defecto).

## POST /api/auth/token

Atajo de autenticación documentado en `docs/decisiones.md` (punto 5).

**Body** `{ "usuarioId": 1, "retoId": "uuid-del-reto" }`

**Respuesta 200** `{ "token": "eyJhbGciOi..." }`

## POST /api/retos

**Body** `{ "nombre": "...", "iniciaEn": "ISO-8601", "terminaEn": "ISO-8601" }`

**Respuesta 201**: objeto `Reto`.

## POST /api/retos/:retoId/aportes

Requiere `Authorization: Bearer <token>`. El `usuarioId` del body debe
coincidir con el del token (403 si no).

**Body** `{ "usuarioId": 1, "pasos": 1250 }`

| Código | Significado |
|---|---|
| 201 | Aporte registrado. Responde `{ "registrado": true, "tabla": [...] }` |
| 403 | El token no corresponde a ese `usuarioId` |
| 422 | Incremento no plausible (RF-06, más de 250 pasos/min) |

## GET /api/retos/:id/tabla

Tabla de posiciones cacheada en memoria (última calculada). Útil para
pantallas que no necesitan WebSocket.

**Respuesta 200** `{ "tabla": [{ "id": 1, "nombre": "Ficha 3278641", "total": 4200, "puesto": 1 }] }`

## WebSocket

Conexión con `auth: { token }`. El servidor rechaza la conexión sin token
válido o expirado.

**Evento `tabla:actual`** (servidor → cliente): se emite al conectarse y
cada vez que cualquier usuario del reto reporta un aporte. Mismo formato
que `GET /api/retos/:id/tabla`.

## GET /salud

Chequeo de disponibilidad. `{ "estado": "ok" }`.
