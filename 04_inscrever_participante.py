import os, psycopg
from dotenv import load_dotenv

load_dotenv()

def conectar_banco() -> psycopg.Connection:
    """Cria e retorna uma conexão segura com o PostgreSQL na Aiven."""
    return psycopg.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        sslmode=os.getenv("DB_SSLMODE", "require"),
        options="-c search_path=gestao,public",
    )


def inscrever_participante(
    id_participante: int,
    id_evento: int,
    forma_pagamento: str,
) -> None:
    """
    Inscreve um participante em um evento dentro de uma transação,
    validando existência de vagas, coerência de pagamento e duplicidade.
    """
    try:
        with conectar_banco() as conn:
            with conn.transaction():
                with conn.cursor() as cur:
                    # 1. Valida se o participante existe
                    cur.execute(
                        "SELECT nome FROM participante WHERE id = %s;",
                        (id_participante,),
                    )
                    participante = cur.fetchone()
                    if not participante:
                        raise ValueError(
                            f"Participante com id={id_participante} não encontrado."
                        )

                    # 2. Bloqueia a linha do evento (FOR UPDATE) para evitar disputa simultânea por vagas
                    cur.execute(
                        """
                        SELECT nome, capacidade_maxima, preco_ingresso
                        FROM evento
                        WHERE id = %s
                        FOR UPDATE;
                        """,
                        (id_evento,),
                    )
                    evento = cur.fetchone()
                    if not evento:
                        raise ValueError(f"Evento com id={id_evento} não encontrado.")

                    nome_evento, capacidade_maxima, preco_ingresso = evento

                    # 3. Valida coerência entre preço do ingresso e forma de pagamento
                    if preco_ingresso == 0:
                        forma_pagamento = "Gratuito"
                    elif forma_pagamento == "Gratuito":
                        raise ValueError(
                            f"O evento '{nome_evento}' é pago (R$ {preco_ingresso:.2f}). "
                            "Informe PIX, Cartão de Crédito, Cartão de Débito ou Boleto."
                        )

                    # 4. Verifica quantas inscrições já existem para este evento
                    cur.execute(
                        "SELECT COUNT(*) FROM inscricao WHERE id_evento = %s;",
                        (id_evento,),
                    )
                    total_inscritos = cur.fetchone()[0]

                    if total_inscritos >= capacidade_maxima:
                        raise RuntimeError(
                            f"Inscrição recusada: '{nome_evento}' está lotado "
                            f"({total_inscritos}/{capacidade_maxima} vagas preenchidas)."
                        )

                    # 5. Insere a inscrição utilizando parâmetros (%s) contra SQL Injection
                    cur.execute(
                        """
                        INSERT INTO inscricao (
                            id_participante,
                            id_evento,
                            forma_pagamento,
                            compareceu
                        )
                        VALUES (%s, %s, %s, FALSE)
                        RETURNING id;
                        """,
                        (id_participante, id_evento, forma_pagamento),
                    )
                    id_inscricao = cur.fetchone()[0]

        vagas_restantes = capacidade_maxima - (total_inscritos + 1)
        print(
            f"Sucesso! Inscrição #{id_inscricao} confirmada para '{participante[0]}' "
            f"no evento '{nome_evento}'. Vagas restantes: {vagas_restantes}."
        )

    except psycopg.errors.UniqueViolation:
        print(
            f"Aviso: o participante id={id_participante} já está inscrito no evento id={id_evento}."
        )
    except (ValueError, RuntimeError, psycopg.Error) as erro:
        print(f"Operação cancelada (Rollback executado): {erro}")


if __name__ == "__main__":
    inscrever_participante(
        id_participante=19,
        id_evento=12,
        forma_pagamento="PIX",
    )