# Decisiones técnicas · P7 Reto de pasos entre fichas

> Completen los `[POR COMPLETAR]` con datos de su prueba real antes de
> entregar (semana 5).

## 1. El problema difícil: corrección de reinicios del contador

`Pedometer.stepCountStream` entrega pasos **desde el último arranque del
equipo**, no pasos del día. La guía didáctica del banco incluye un
fragmento de referencia para resolver esto que tiene un desajuste entre
el comentario y el código: el comentario dice *"la nueva base es la
lectura actual"*, pero el código de ejemplo fija la base en `0` tras un
reinicio. Si se sigue el código literal, el **siguiente** evento después
del reinicio vuelve a sumar por completo el valor ya contabilizado en el
evento del reinicio (doble conteo).

**Esta implementación (`CorrectorPasos`) fija la nueva base en la lectura
cruda actual, tanto si hubo reinicio como si no.** Está cubierto por
pruebas explícitas en `test/corrector_pasos_test.dart`, incluyendo un caso
que reproduce dos eventos consecutivos tras un reinicio para demostrar que
no hay doble conteo.

`[POR COMPLETAR]`: describir qué pasó en su prueba de campo real al forzar
un reinicio del equipo a mitad de una sesión de captura (capturar
pantalla o video para el informe).

## 2. Límite de 250 pasos/minuto (RF-06)

Aplicado en dos capas independientes:
- **Cliente** (`CorrectorPasos.actualizar`): descarta el delta antes de
  guardarlo localmente, para no acumular un valor erróneo que luego haya
  que corregir.
- **Servidor** (`api/src/servicios/validacionAporte.js`): vuelve a
  validar de forma independiente, porque el cliente es manipulable
  (regla del banco de proyectos: toda regla de negocio que alguien tenga
  incentivo para burlar se valida en el servidor).

El umbral de 250 pasos/min equivale a una cadencia de corredor rápido;
está definido en el enunciado, no fue elegido por el equipo.

## 3. Frecuencia de envío al servidor

El enunciado (RF-03) pide enviar el acumulado "por horas". Para que la
demostración en clase sea observable de inmediato, la app de referencia
reporta cada vez que el acumulado crece al menos 10 pasos en vez de
esperar una hora completa.

`[POR COMPLETAR]`: si el equipo cambió esto a un `Timer.periodic` de una
hora real para la entrega final, documentar aquí el intervalo elegido y
por qué.

## 4. Qué pasa si se pierde la conexión durante la captura

El aporte que falla por red no se reintenta automáticamente en esta
versión (queda como extensión natural: cola local con SQLite, igual que
P1 y P3 del banco). El acumulado de pasos en sí **nunca se pierde**,
porque se persiste en `SharedPreferences` en cada evento del podómetro,
independientemente de si el envío al servidor tuvo éxito.

`[POR COMPLETAR]`: si el equipo implementó la cola de reintento como
extensión, documentar el diseño aquí.

## 5. Autenticación simplificada

El endpoint `POST /api/auth/token` de este proyecto es un atajo
documentado: emite un JWT a partir de un `usuarioId` y `retoId` ya
existentes en la base de datos, sin pedir contraseña. El banco de
proyectos ya resuelve el login completo (usuario/contraseña + rotación de
refresh token) en **P4 · Asistencia biométrica**; en una integración real
del banco completo, P7 reutilizaría ese mecanismo en vez de duplicarlo.

## 6. Qué se probó en un equipo de gama baja

`[POR COMPLETAR]`: equipo usado, si el sensor de pasos por hardware
estaba disponible (según la matriz de cobertura del banco, falta en
equipos de gama baja) y cómo se comportó el conteo en segundo plano con
la pantalla apagada.
