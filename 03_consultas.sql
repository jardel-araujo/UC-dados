SET search_path TO agenda, public;

--- Quais eventos acontecem no próximo mês, em ordem de data?
SELECT
    e.id,
    e.nome AS evento,
    e.data_evento,
    e.horario,
    e.preco_ingresso,
    l.nome AS local,
    c.nome AS categoria
FROM evento e
JOIN local l ON e.id_local = l.id
JOIN categoria c ON e.id_categoria = c.id
WHERE DATE_TRUNC('month', e.data_evento) = DATE_TRUNC('month', CURRENT_DATE + INTERVAL '1 month')
ORDER BY e.data_evento ASC, e.horario ASC;

--- Quantas inscrições cada evento teve, e qual a taxa de ocupação (inscrições ÷ capacidade)?
SELECT
    e.id,
    e.nome AS evento,
    e.capacidade_maxima,
    COUNT(i.id) AS total_inscricoes,
    ROUND((COUNT(i.id)::NUMERIC / e.capacidade_maxima) * 100, 2) AS taxa_ocupacao_percentual
FROM evento e
LEFT JOIN inscricao i ON e.id = i.id_evento
GROUP BY e.id, e.nome, e.capacidade_maxima
ORDER BY taxa_ocupacao_percentual DESC, e.id ASC;

-- Qual a taxa de comparecimento por categoria de evento?
SELECT
    c.id,
    c.nome AS categoria,
    COUNT(i.id) AS total_inscricoes,
    SUM(CASE WHEN i.compareceu THEN 1 ELSE 0 END) AS total_comparecimentos,
    COALESCE(
        ROUND((SUM(CASE WHEN i.compareceu THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(i.id), 0)) * 100, 2),
        0.00
    ) AS taxa_comparecimento_percentual
FROM categoria c
LEFT JOIN evento e ON c.id = e.id_categoria
LEFT JOIN inscricao i ON e.id = i.id_evento
GROUP BY c.id, c.nome
ORDER BY taxa_comparecimento_percentual DESC, c.nome ASC;

--- Quais participantes se inscreveram em mais de 3 eventos?
SELECT
    p.id,
    p.nome AS participante,
    p.email,
    COUNT(i.id) AS quantidade_eventos
FROM participante p
JOIN inscricao i ON p.id = i.id_participante
GROUP BY p.id, p.nome, p.email
HAVING COUNT(i.id) > 3
ORDER BY quantidade_eventos DESC, p.nome ASC;

--- Quais locais nunca receberam um evento?
SELECT
    l.id,
    l.nome AS local,
    l.endereco,
    l.bairro,
    l.cidade
FROM local l
LEFT JOIN evento e ON l.id = e.id_local
WHERE e.id IS NULL
ORDER BY l.id ASC;

--- A receita total por local, considerando apenas eventos pagos?
SELECT
    l.id,
    l.nome AS local,
    COALESCE(SUM(e.preco_ingresso), 0.00) AS receita_total
FROM local l
LEFT JOIN evento e ON l.id = e.id_local AND e.preco_ingresso > 0
LEFT JOIN inscricao i ON e.id = i.id_evento
GROUP BY l.id, l.nome
ORDER BY receita_total DESC, l.nome ASC;

--- View com o detalhamento das inscrições
CREATE OR REPLACE VIEW vw_detalhamento_inscricoes AS
SELECT
    i.id AS id_inscricao,
    p.nome AS participante,
    p.email AS email_participante,
    e.nome AS evento,
    c.nome AS categoria,
    l.nome AS local,
    l.cidade AS cidade_local,
    e.data_evento,
    e.horario,
    i.data_inscricao,
    i.forma_pagamento,
    CASE WHEN i.compareceu THEN 'Sim' ELSE 'Não' END AS compareceu
FROM inscricao i
JOIN participante p ON i.id_participante = p.id
JOIN evento e ON i.id_evento = e.id
JOIN categoria c ON e.id_categoria = c.id
JOIN local l ON e.id_local = l.id;

-- Consulta de exemplo na view criada:
-- SELECT * FROM vw_detalhamento_inscricoes ORDER BY data_evento ASC, id_inscricao ASC;