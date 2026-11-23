CREATE DATABASE roteiro_cultural_ceara;
CREATE SCHEMA IF NOT EXISTS agenda;
alter database roteiro_cultural_ceara set search_path to agenda, public;

CREATE TABLE categoria (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT
);

CREATE TABLE local (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(150) NOT NULL,
    bairro VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL
);

CREATE TABLE evento (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    data_evento DATE NOT NULL,
    horario TIME NOT NULL,
    preco_ingresso NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (preco_ingresso >= 0),
    capacidade_maxima INT NOT NULL CHECK (capacidade_maxima > 0),
    id_categoria INT NOT NULL,
    id_local INT NOT NULL,
    CONSTRAINT fk_evento_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id) ON DELETE RESTRICT,
    CONSTRAINT fk_evento_local FOREIGN KEY (id_local) REFERENCES local (id) ON DELETE RESTRICT
);

CREATE TABLE participante (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL CHECK (data_nascimento < CURRENT_DATE),
    cidade VARCHAR(80) NOT NULL
);

CREATE TABLE inscricao (
    id SERIAL PRIMARY KEY,
    id_participante INT NOT NULL,
    id_evento INT NOT NULL,
    data_inscricao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento VARCHAR(30) NOT NULL CHECK (forma_pagamento IN ('Gratuito', 'PIX', 'Cartão de Crédito', 'Cartão de Débito', 'Boleto')),
    compareceu BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_inscricao_participante FOREIGN KEY (id_participante) REFERENCES participante (id) ON DELETE CASCADE,
    CONSTRAINT fk_inscricao_evento FOREIGN KEY (id_evento) REFERENCES evento (id) ON DELETE CASCADE,
    CONSTRAINT uq_participante_evento UNIQUE (id_participante, id_evento)
);


ALTER TABLE participante ADD COLUMN telefone VARCHAR(20);


CREATE INDEX idx_evento_data_evento ON evento (data_evento);
CREATE INDEX idx_inscricao_id_evento ON inscricao (id_evento);
