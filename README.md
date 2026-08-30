# P7 · Reto de pasos entre fichas

Actividad No. 5 — SENA ADSO, ficha 3278641. Actividad física, tabla de
posiciones en vivo y notificaciones push.

## Estructura

```
proyecto-p07/
├── app/     # Flutter + Riverpod + pedometer + socket_io_client
├── api/     # Node.js + Express + Socket.IO + Prisma + PostgreSQL
└── docs/    # decisiones.md (el problema difícil está documentado aquí), contrato-api.md
```

## Backend (`api/`)

```bash
cd api
cp .env.example .env
npm install
npx prisma migrate dev
npm run dev                # REST + WebSocket en http://localhost:3000
```

Necesitarás datos de prueba mínimos antes de usar la app (una ficha, un
usuario y un reto):
```sql
INSERT INTO ficha (nombre) VALUES ('Ficha 3278641');
INSERT INTO usuario (nombre, ficha_id) VALUES ('Aprendiz de prueba', 1);
INSERT INTO reto (nombre, inicia_en, termina_en) VALUES ('Reto de agosto', now(), now() + interval '30 days');
```

Pruebas (sin base de datos):
```bash
npm test
```

## Frontend (`app/`)

```bash
cd app
flutter pub get
flutter run
```

Ajusta `baseUrlApi` en `lib/presentacion/providers/proveedores_nucleo.dart`
y los IDs de ejemplo en `lib/main.dart` (usuarioId, fichaId, retoId) con
los datos reales que insertaste en la base de datos.

Pruebas sin dispositivo (corrector de pasos — el núcleo de este proyecto):
```bash
flutter test
```

## Requisitos funcionales cubiertos

| RF | Descripción | Dónde |
|---|---|---|
| RF-01 | Contador de pasos del sistema, no acelerómetro propio | `datos/servicios/contador_pasos.dart` (usa `pedometer`) |
| RF-02 | Sigue contando con la app cerrada | Limitación de plataforma documentada en README (ver nota abajo) |
| RF-03 | Envío por horas, tolerante a reinicios | `dominio/servicios/corrector_pasos.dart` |
| RF-04 | Tabla en tiempo real por WebSocket | `tiempo-real/tabla.js` + `datos/datasources/socket_reto_datasource.dart` |
| RF-05 | Notificación push al ser superado | `servicios/notificaciones.js` (`detectarAdelantamientos`, integración FCM real pendiente) |
| RF-06 | Descarta incrementos imposibles | `servicios/validacionAporte.js` (servidor) + `corrector_pasos.dart` (cliente) |

## Nota sobre RF-02 (captura en segundo plano)

El paquete `pedometer` mantiene el stream activo mientras la app está en
segundo plano en la mayoría de fabricantes Android, pero **no garantiza
funcionamiento tras el cierre forzado de la app** ni en fabricantes con
gestión agresiva de batería (Xiaomi, Huawei, algunos Samsung). Para
garantizarlo de forma robusta se necesitaría un foreground service nativo,
fuera del alcance de esta actividad. Documentar el comportamiento
observado en `docs/decisiones.md`.

## Criterios bloqueantes — checklist antes de sustentar

- [ ] Reiniciar el equipo no borra ni duplica los pasos del día (demostrado en vivo; cubierto por pruebas en `corrector_pasos_test.dart`).
- [ ] La tabla se actualiza en otro dispositivo sin recargar la pantalla.
- [ ] El WebSocket rechaza conexiones sin token válido (`io.use` en `tabla.js`).
- [ ] Existe validación de incrementos imposibles del lado del servidor, no solo del cliente (`validacionAporte.js`, probado).

## Pendiente por completar (equipo)

1. `npx prisma migrate dev` contra su base de datos real + datos de prueba (ver arriba).
2. Integrar Firebase Cloud Messaging real en `servicios/notificaciones.js` (hay un `TODO` marcado) y `firebase_messaging` en el cliente.
3. Probar el reinicio real del equipo a mitad de sesión y documentar en `docs/decisiones.md`.
4. Ajustar `baseUrlApi` e IDs de ejemplo en el cliente.
5. Mínimo 8 commits descriptivos repartidos en el tiempo de desarrollo.
