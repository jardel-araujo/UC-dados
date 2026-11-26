# Roteiro Cultural do Ceará — Análise de Dados e Banco PostgreSQL

Projeto prático desenvolvido como desafio de conclusão do curso de **Análise de Dados (SENAC Ceará)**, focado na modelagem relacional, manipulação e consulta de dados em **PostgreSQL** e automação de processos e relatórios em **Python**.

## Visão Geral do Projeto

O projeto simula a gestão e o acompanhamento de eventos culturais em espaços de Fortaleza/CE (como *Theatro José de Alencar*, *Centro Dragão do Mar*, *Cineteatro São Luiz*, *Estação das Artes*, *Caixa Cultural Fortaleza* e *Teatro Municipal São José*), cobrindo desde a estruturação das tabelas até a geração de relatórios de ocupação em CSV e Excel[cite: 4, 7].

### Principais funcionalidades e entregas

* **Modelagem e DDL (`01_ddl.sql`):** Criação do banco `roteiro_cultural_ceara`, schema `agenda`, tabelas (`categoria`, `local`, `evento`, `participante`, `inscricao`), chaves primárias/estrangeiras, restrições de integridade (`CHECK`, `UNIQUE`, `NOT NULL`), alteração de coluna (`telefone`) e índices de consulta[cite: 3].
* **Carga e manipulação de dados (`02_dml.sql`):** População com categorias, locais, eventos, participantes e inscrições, além de exemplos de `UPDATE`, `DELETE` e transação explícita (`BEGIN` / `COMMIT`)[cite: 4].
* **Consultas analíticas e View (`03_consultas.sql`):** Consultas para eventos do próximo mês, taxa de ocupação por evento, taxa de comparecimento por categoria, participantes com mais de 3 inscrições, locais sem eventos, receita de eventos pagos e criação da view `vw_detalhamento_inscricoes`[cite: 5].
* **Inscrição transacional em Python (`04_inscrever_participante.py`):** Validação de participante e evento, bloqueio concorrente com `FOR UPDATE`, verificação de coerência entre ingresso gratuito/pago e forma de pagamento, controle de capacidade máxima, prevenção a SQL Injection com parâmetros (`%s`) e tratamento de exceções com *rollback*[cite: 6].
* **Relatório de ocupação em CSV e Excel (`05_relatorio_ocupacao.py`):** Extração via `psycopg` + `pandas` e exportação automatizada para `ocupacao_eventos.csv` (separador `;`, UTF-8 com BOM) e `ocupacao_eventos.xlsx`[cite: 7].

---

## Estrutura do Repositório

```text
UC-dados/
├── .gitignore
├── 01_ddl.sql
├── 02_dml.sql
├── 03_consultas.sql
├── 04_inscrever_participante.py
├── 05_relatorio_ocupacao.py
├── ocupacao_eventos.csv
├── ocupacao_eventos.xlsx
└── README.md
```
[cite: 2, 3, 4, 5, 6, 7]

---

## Tecnologias Utilizadas

* **Banco de Dados:** PostgreSQL (hospedado na nuvem via Aiven)[cite: 1, 6]
* **Linguagem:** Python 3[cite: 6, 7]
* **Bibliotecas Python:** `psycopg`, `pandas`, `python-dotenv`, `openpyxl` (para exportação `.xlsx`)[cite: 6, 7]
* **Controle de Versão:** Git e GitHub

---

## Configuração do Ambiente

1. **Clone o repositório:**

   ```bash
   git clone [https://github.com/jardel-araujo/UC-dados.git](https://github.com/jardel-araujo/UC-dados.git)
   cd UC-dados
   ```

2. **Crie e ative um ambiente virtual (opcional, recomendado):**

   ```bash
   python -m venv .venv
   # Windows (PowerShell):
   .venv\Scripts\Activate.ps1
   ```

3. **Instale as dependências:**

   ```bash
   pip install psycopg[binary] pandas python-dotenv openpyxl
   ```

4. **Configure o arquivo `.env` na raiz do projeto** (não versionado pelo `.gitignore`)[cite: 2]:

   ```env
   DB_HOST=seu_host_postgresql
   DB_PORT=11526
   DB_NAME=roteiro_cultural_ceara
   DB_USER=seu_usuario
   DB_PASSWORD=sua_senha
   DB_SSLMODE=require
   ```
  [cite: 1, 2]

---

## Como Executar

### 1. Banco de Dados (SQL)
Execute os scripts na ordem no seu cliente SQL ou `psql`:
1. `01_ddl.sql` — cria a estrutura de tabelas, restrições e índices[cite: 3].
2. `02_dml.sql` — insere os registros iniciais e executa operações de manipulação[cite: 4].
3. `03_consultas.sql` — executa as consultas analíticas e cria a view `vw_detalhamento_inscricoes`[cite: 5].

> **Observação técnica:** Os scripts SQL (`01_ddl.sql`, `02_dml.sql` e `03_consultas.sql`) utilizam o schema `agenda`[cite: 3, 4, 5], enquanto os scripts Python (`04_inscrever_participante.py` e `05_relatorio_ocupacao.py`) configuram `search_path=gestao,public` na conexão[cite: 6, 7]. Certifique-se de que o schema configurado na conexão corresponda ao schema onde as tabelas foram criadas no seu banco.

### 2. Scripts Python

* **Registrar inscrição com validações:**
  ```bash
  python 04_inscrever_participante.py
  ```
 [cite: 6]

* **Gerar relatórios de ocupação (`ocupacao_eventos.csv` e `ocupacao_eventos.xlsx`):**
  ```bash
  python 05_relatorio_ocupacao.py
  ```
 [cite: 7]

---

## Autor

**Jardel Araújo Jerônimo**  
Projeto de conclusão — Curso de Análise de Dados (SENAC CE)  
GitHub: [@jardel-araujo](https://github.com/jardel-araujo)
