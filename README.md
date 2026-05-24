# Keys Store — E-commerce de Chaves de Jogos

Banco de dados PostgreSQL de uma loja de chaves de jogos digitais, com aplicação em **Lazarus / Free Pascal**.
As capas dos jogos são guardadas **dentro do banco** (coluna `BYTEA`), então o backup é **autocontido**: um único arquivo `.sql` recria todas as tabelas **e** todas as imagens, sem precisar de arquivos avulsos.

---

## Estrutura do repositório

```
keys-store/
├── README.md                  -> este arquivo
├── .gitignore                 
├── database/
│   ├── keys_bd_dump.sql       -> dump completo (estrutura + dados + imagens) 
│   └── schema.sql             -> apenas a estrutura das tabelas
├── src/                       -> codigo-fonte do projeto Lazarus 
└── docs/                      -> artigo, diagramas ER, prints, etc.
```

---

## Pré-requisitos

- **PostgreSQL**   vem com o **pgAdmin 4** e o **SQL Shell (psql)** juntos.
- **Lazarus** com **ZeosLib**.

---

## Como restaurar o banco (passo a passo testado)

O dump **não cria o banco sozinho**. O fluxo é: 
1.Criar um banco vazio no pgAdmin e 
2.Importar os dados pelo SQL Shell (psql). As imagens já estão embutidas no `.sql`.

### Passo 1 — Criar o banco vazio (pgAdmin)

1.Abra o **pgAdmin 4** e conecte no servidor **PostgreSQL**.
2. Clique com o botão direito em **Databases** -> **Create** -> **Database…**
3. Em **Database**, digite o nome: **`keys_bd`**
4. Clique em **Save**.

> Pronto, o banco `keys_bd` existe mas está vazio. A importação dos dados é feita no Passo 2.

### Passo 2 — Importar os dados (SQL Shell / psql)

> **Importante:** O dump usa deve ser rodado no **psql**, **não** no Query Tool do pgAdmin (lá o comando `\i` dá erro de sintaxe). Use o SQL Shell.

1. Abra o **SQL Shell (psql)**.
2. Responda às perguntas de conexão — **Enter**. Exceto a `database` que dever ser o mesmo nome do bd ciado anteriormente.

3. Já conectado (`keys_bd=#`), rode o comando `\i` apontando para o dump.
   **Use barras normais `/` e aspas simples `'`** (mesmo no Windows):

   ```
   \i 'C:/caminho_até_o_dump/keys_bd_dump.sql'
   ```

---

## Conferir que as imagens foram restauradas

No Query Tool do pgAdmin, rode: 
`Select * from games`


Devem aparecer **40 linhas**, todas com `bytes` > 0. 

---

