-- P7 · Reto de pasos entre fichas

CREATE TABLE ficha (
  id SERIAL PRIMARY KEY,
  nombre TEXT UNIQUE NOT NULL
);

CREATE TABLE usuario (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  ficha_id INT NOT NULL REFERENCES ficha(id)
);

CREATE TABLE reto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  inicia_en TIMESTAMPTZ NOT NULL,
  termina_en TIMESTAMPTZ NOT NULL
);

CREATE TABLE aporte (
  id BIGSERIAL PRIMARY KEY,
  usuario_id INT NOT NULL REFERENCES usuario(id),
  reto_id UUID NOT NULL REFERENCES reto(id),
  pasos INT NOT NULL CHECK (pasos >= 0),
  creado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_aporte_reto ON aporte (reto_id);
CREATE INDEX idx_aporte_usuario_reto ON aporte (usuario_id, reto_id);
