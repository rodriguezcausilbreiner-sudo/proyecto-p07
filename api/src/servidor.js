import 'dotenv/config';
import { createServer } from 'node:http';
import { Server } from 'socket.io';
import app from './app.js';
import { montarTiempoReal } from './tiempo-real/tabla.js';

const PUERTO = process.env.PORT || 3000;

const servidorHttp = createServer(app);
const io = new Server(servidorHttp, { cors: { origin: '*' } });
montarTiempoReal(io);

servidorHttp.listen(PUERTO, () => {
  console.log(`API P7 · Reto de pasos escuchando en http://localhost:${PUERTO} (REST + WebSocket)`);
});
