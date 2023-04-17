DROP SCHEMA IF EXISTS tiger CASCADE;

DROP SCHEMA IF EXISTS tiger_data CASCADE;

DROP SCHEMA IF EXISTS topology CASCADE;

CREATE TABLE IF NOT EXISTS public.postos_coleta(
	id_posto SERIAL NOT NULL PRIMARY KEY,
	endereco_completo TEXT NOT NULL,
	nome_posto VARCHAR(255),
	atualizado_em TIMESTAMP(0) NOT NULL DEFAULT NOW(),
	latitude FLOAT,
	longitude FLOAT
);

CREATE TABLE IF NOT EXISTS public.compostagens(
	id_compostagem SERIAL NOT NULL PRIMARY KEY,
	quantidade_kg FLOAT,
	publicado_em TIMESTAMP(0) NOT NULL DEFAULT NOW(),
	publicado_por VARCHAR(255),
	recolhido_em TIMESTAMP(0),
	foi_recolhido boolean DEFAULT FALSE,
	posto_fk INT NOT NULL,
	CONSTRAINT compostagem_fk FOREIGN KEY (posto_fk) REFERENCES public.postos_coleta(id_posto) ON DELETE CASCADE
);

-- Postos de coleta previamente cadastrados
INSERT INTO
	public.postos_coleta (
		endereco_completo,
		nome_posto,
		latitude,
		longitude
	)
VALUES
	(
		'Avenida Lineu De Moura, Urbanova, São José Dos Campos - Sp, 12244-380',
		'GUEDES COCANA',
		-23.1957503,
		-45.9307757
	),
	(
		'Avenida Rui Barbosa, Santana, São José Dos Campos - Sp',
		'ECOPATIOARCA21',
		-23.1554186,
		-45.9013595
	),
	(
		'R. Eng. Prudente Meireles de Morais, 305 - Vila Adyana, São José dos Campos - SP, 12243-750',
		'NIBS JUICE BAR',
		-23.19709799312104,
		-45.89630216400873
	),
	(
		'Av. Dr. João Baptista Soares de Queiroz Júnior, 950 - Jardim das Industrias, São José dos Campos - SP, 12240-000',
		'ESPAÇO GOURMET CHEF THAIS OKAMOTO',
		-23.225074596895237,
		-45.91713138433457
	);

-- Valores default para não bugar o mapa
INSERT INTO
	public.compostagens(quantidade_kg, publicado_por, posto_fk)
VALUES
	(0, '_default', 1);

INSERT INTO
	public.compostagens(quantidade_kg, publicado_por, posto_fk)
VALUES
	(0, '_default', 2);

INSERT INTO
	public.compostagens(quantidade_kg, publicado_por, posto_fk)
VALUES
	(0, '_default', 3);

INSERT INTO
	public.compostagens(quantidade_kg, publicado_por, posto_fk)
VALUES
	(0, '_default', 4);