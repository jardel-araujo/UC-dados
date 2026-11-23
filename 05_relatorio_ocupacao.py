import os
from dotenv import load_dotenv
import pandas as pd
import psycopg
from psycopg.rows import dict_row

load_dotenv()


def conectar_banco() -> psycopg.Connection:
    """Cria conexão com o PostgreSQL usando variáveis do arquivo .env."""
    return psycopg.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        sslmode=os.getenv("DB_SSLMODE", "require"),
        options="-c search_path=gestao,public",
    )


def gerar_relatorio_ocupacao(
    caminho_csv: str = "ocupacao_eventos.csv",
    caminho_excel: str = "ocupacao_eventos.xlsx",
) -> pd.DataFrame:
    """Consulta a ocupação de cada evento e exporta para CSV e Excel usando pandas."""
    sql = """
        SELECT
            e.id AS id_evento,
            e.nome AS evento,
            c.nome AS categoria,
            l.nome AS local,
            e.data_evento,
            e.horario,
            e.preco_ingresso,
            e.capacidade_maxima,
            COUNT(i.id) AS total_inscricoes,
            (e.capacidade_maxima - COUNT(i.id)) AS vagas_restantes,
            ROUND((COUNT(i.id)::NUMERIC / e.capacidade_maxima) * 100, 2) AS taxa_ocupacao_percentual
        FROM evento e
        JOIN categoria c ON e.id_categoria = c.id
        JOIN local l ON e.id_local = l.id
        LEFT JOIN inscricao i ON e.id = i.id_evento
        GROUP BY
            e.id,
            e.nome,
            c.nome,
            l.nome,
            e.data_evento,
            e.horario,
            e.preco_ingresso,
            e.capacidade_maxima
        ORDER BY e.data_evento ASC, e.id ASC;
    """

    try:
        with conectar_banco() as conn:
            with conn.cursor(row_factory=dict_row) as cur:
                cur.execute(sql)
                linhas = cur.fetchall()

        df = pd.DataFrame(linhas)

        if not df.empty:
            df["preco_ingresso"] = df["preco_ingresso"].astype(float)
            df["taxa_ocupacao_percentual"] = df["taxa_ocupacao_percentual"].astype(float)

        df.to_csv(caminho_csv, index=False, sep=";", encoding="utf-8-sig")
        df.to_excel(caminho_excel, index=False, sheet_name="Ocupacao_Eventos")

        print(f"Relatórios gerados com sucesso: '{caminho_csv}' e '{caminho_excel}'.")
        return df

    except psycopg.Error as erro:
        print(f"Erro ao gerar relatório no PostgreSQL: {erro}")
        raise


if __name__ == "__main__":
    df_resultado = gerar_relatorio_ocupacao()
    if not df_resultado.empty:
        print(
            df_resultado[
                ["id_evento", "evento", "capacidade_maxima", "total_inscricoes", "taxa_ocupacao_percentual"]
            ].to_string(index=False)
        )