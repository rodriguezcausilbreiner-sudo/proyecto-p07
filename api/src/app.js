import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rutas from './rutas/index.js';
import { manejadorErrores, rutaNoEncontrada } from './middlewares/errores.js';

const app = express();

app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json({ limit: '256kb' }));

app.get('/salud', (req, res) => res.json({ estado: 'ok' }));

app.use('/api', rutas);

app.use(rutaNoEncontrada);
app.use(manejadorErrores);

export default app;
