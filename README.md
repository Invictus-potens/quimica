# Especificação de Projeto: Sistema de Gestão de Pedidos

## 1. Arquitetura e Stack Tecnológico
O sistema adota uma arquitetura headless, separando a interface do usuário da lógica de negócios e persistência de dados.

* **Frontend:** Next.js (Consumidor da API)
* **Backend:** PHP / Laravel (API RESTful)
* **Autenticação:** Laravel Sanctum (Gerenciamento de tokens de API)
* **Banco de Dados:** PostgreSQL

---

## 2. Controle de Acesso Baseado em Perfis (RBAC)

### 👑 Gestor (Super User)
Este é o perfil com poder total sobre o fluxo da aplicação. Ele orquestra os clientes e os pedidos.

* **Gestão de Clientes:** Pode criar novos cadastros na tabela `clientes`, visualizar a lista completa de empresas, editar dados cadastrais e remover (via soft delete) perfis do sistema.
* **Gestão de Pedidos:** Tem controle para criar novos registros na tabela `pedidos`, editar informações (como título, lote e validade), atribuir o pedido a um `cliente_id` específico e também deletar pedidos.
* **Controle de Status:** Possui permissão exclusiva para alterar o `status_atual` do pedido e registrar as mudanças na tabela `etapas_pedido` para manter o histórico de rastreabilidade.
* **Gestão de Arquivos:** Pode anexar documentos em qualquer pedido do sistema, visualizar a lista completa de arquivos (tanto os internos quanto os enviados pelo cliente) e remover documentos quando necessário.
* **Visão Global:** Tem acesso irrestrito de leitura para listar, filtrar e auditar todos os dados do banco.

### 👤 Cliente
Este perfil tem um escopo de acesso estritamente fechado, limitando-se apenas aos recursos que o Gestor atribuiu a ele.

* **Perfil Próprio:** Só consegue visualizar os dados referentes ao seu próprio cadastro na tabela `clientes` (nome da empresa, CNPJ, etc.). Não enxerga outros clientes do sistema.
* **Acompanhamento de Pedidos:** Pode listar e visualizar os detalhes apenas dos `pedidos` vinculados ao seu próprio `cliente_id`. É estritamente proibido de criar, editar ou excluir pedidos.
* **Visualização de Status:** Consegue consultar o `status_atual` e ler o histórico de `etapas_pedido` das suas solicitações para saber o andamento das coisas, sem permissão de alteração.
* **Envio de Arquivos:** Pode fazer upload de novos `arquivos`, mas apenas apontando para os `pedidos` que pertencem a ele. Também pode visualizar e fazer download dos documentos anexados em seus projetos (enviados por ele mesmo ou pelo gestor).

---

## 3. Modelagem de Dados (Diagrama ER)

```mermaid
erDiagram
    perfis ||--o{ usuarios : "possui"
    usuarios ||--o| clientes : "pode ser"
    usuarios ||--o{ arquivos : "envia"
    usuarios ||--o{ pedidos : "cadastra"
    clientes ||--o{ pedidos : "tem"
    pedidos ||--o{ etapas_pedido : "passa por"
    pedidos ||--o{ arquivos : "contem"

    perfis {
        uuid id PK
        varchar nome
    }

    usuarios {
        uuid id PK
        uuid perfil_id FK
        varchar login
        varchar password
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    clientes {
        uuid id PK
        uuid usuario_id FK
        varchar nome_empresa
        varchar cnpj
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    pedidos {
        uuid id PK
        uuid cliente_id FK
        uuid criado_por_id FK
        varchar titulo
        varchar codigo_lote
        date data_validade
        enum status_atual
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    etapas_pedido {
        uuid id PK
        uuid pedido_id FK
        varchar nome_etapa
        enum status
        timestamp created_at
        timestamp updated_at
    }

    arquivos {
        uuid id PK
        uuid pedido_id FK
        uuid usuario_id FK
        varchar nome_arquivo
        varchar descricao
        text url_arquivo
        enum tipo
        enum origem
        timestamp created_at
        timestamp deleted_at
    }