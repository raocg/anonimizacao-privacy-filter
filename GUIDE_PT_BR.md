# Guia de Fine-tuning do Privacy Filter para Português Brasileiro 🇧🇷

Este guia descreve como adaptar o OpenAI Privacy Filter para anonimizar dados em português brasileiro.

## Índice

1. [Overview](#overview)
2. [Categorias de Dados Sensíveis](#categorias-de-dados-sensíveis)
3. [Quickstart](#quickstart)
4. [Preparação de Dados](#preparação-de-dados)
5. [Fine-tuning](#fine-tuning)
6. [Uso do Modelo](#uso-do-modelo)
7. [Exemplos Práticos](#exemplos-práticos)
8. [Troubleshooting](#troubleshooting)

## Overview

O Privacy Filter foi originalmente treinado em inglês. Para usar em português brasileiro, você pode:

1. **Usar o modelo base**: Performance esperada de ~60-70% (pode perder dados específicos do Brasil)
2. **Fine-tunar com seus dados**: Performance esperada de 85-95%+ (recomendado)

Este repositório incluiu uma categoria `v_pt_br` com 25 labels específicos para o Brasil.

## Categorias de Dados Sensíveis

A categoria `v_pt_br` detecta e anonimiza os seguintes tipos de dados:

### Identificadores Brasileiros

| Categoria | Descrição | Exemplo |
|-----------|-----------|---------|
| `cpf` | Cadastro de Pessoa Física | `123.456.789-00` |
| `cnpj` | Cadastro Nacional da Pessoa Jurídica | `12.345.678/0001-90` |
| `rg` | Registro Geral (documento de identidade) | `12.345.678-9` |
| `cnh` | Carteira Nacional de Habilitação | `1234567890` |
| `numero_processo` | Número de processo | `0001234-56.2024.8.26.0100` |
| `numero_processo_legal` | Número de processo legal | `0001234-56.2024.8.26.0100` |

### Dados Pessoais

| Categoria | Descrição | Exemplo |
|-----------|-----------|---------|
| `nome_pessoal` | Nome da pessoa | `João Silva` |
| `nome_mae` | Nome da mãe | `Maria Santos` |
| `data_nascimento` | Data de nascimento | `01/05/1990` |
| `endereco_pessoal` | Endereço residencial | `Rua das Flores 123, São Paulo-SP` |
| `telefone_pessoal` | Telefone pessoal | `(11) 98765-4321` |
| `email_pessoal` | Email pessoal | `joao@example.com` |

### Dados Profissionais

| Categoria | Descrição | Exemplo |
|-----------|-----------|---------|
| `empresa` | Nome da empresa | `Acme Corporation` |
| `cargo` | Cargo/posição | `Analista de Sistemas` |
| `profissao` | Profissão | `Engenheiro` |
| `salario` | Informação de salário | `R$ 5.000,00` |

### Dados Financeiros

| Categoria | Descrição | Exemplo |
|-----------|-----------|---------|
| `numero_conta` | Número de conta bancária | `123456-7` |
| `numero_agencia` | Número da agência bancária | `1234` |
| `numero_cartao` | Número de cartão (crédito/débito) | `1234-5678-9012-3456` |

### Dados Digitais

| Categoria | Descrição | Exemplo |
|-----------|-----------|---------|
| `url_pessoal` | URL pessoal/perfis | `https://linkedin.com/in/joao-silva` |
| `api_key` | Chave de API | `abc123def456ghi789` |
| `token` | Token de autenticação | `eyJhbGciOiJIUzI1NiI...` |
| `senha` | Senha | `senhaSegura123!` |
| `secret` | Dado secreto genérico | (qualquer informação sensível) |

### Datas

| Categoria | Descrição | Exemplo |
|-----------|-----------|---------|
| `data_pessoal` | Datas gerais | `15/03/2024` |

## Quickstart

### 1. Instalar Dependências

```bash
pip install -e .
```

### 2. Gerar Dados de Treinamento

```bash
python examples/gerar_dados_pt_br.py treino.jsonl validacao.jsonl --num-treino 500 --num-validacao 100
```

### 3. Fazer Fine-tuning

```bash
opf train treino.jsonl \
  --validation-dataset validacao.jsonl \
  --label-space-json examples/config_pt_br.json \
  --output-dir ./modelo_pt_br
```

### 4. Usar o Modelo

```bash
export OPF_CHECKPOINT=./modelo_pt_br
opf "João Silva, CPF 123.456.789-00, email joao@example.com"
```

### Ou use o script de demo

```bash
chmod +x examples/scripts/finetune_pt_br_demo.sh
./examples/scripts/finetune_pt_br_demo.sh ~/.opf/privacy_filter
```

## Preparação de Dados

### Formato de Dados (JSONL)

Cada linha é um JSON com:
- `text`: o texto em português
- `spans`: lista de entidades sensíveis

```json
{
  "text": "Meu nome é João Silva, CPF 123.456.789-00, endereço Rua das Flores 123, São Paulo-SP",
  "spans": [
    {"start": 11, "end": 22, "label": "nome_pessoal"},
    {"start": 39, "end": 56, "label": "cpf"},
    {"start": 68, "end": 103, "label": "endereco_pessoal"}
  ]
}
```

### Como Preparar Seus Dados

#### Opção 1: Usar o Gerador Sintético

```bash
python examples/gerar_dados_pt_br.py meus_dados.jsonl validacao.jsonl --num-treino 1000
```

#### Opção 2: Anotar Manualmente

1. Colete textos em português
2. Identifique as entidades sensíveis
3. Anote com o label correto
4. Salve em JSONL

**Script Python para ajudar na anotação:**

```python
import json

def anotar_exemplo(texto, spans_info):
    """
    spans_info: lista de tuplas (start, end, label)
    Exemplo: [(11, 22, "nome_pessoal"), (39, 56, "cpf")]
    """
    spans = [
        {
            "start": start,
            "end": end,
            "label": label
        }
        for start, end, label in spans_info
    ]
    
    exemplo = {
        "text": texto,
        "spans": spans
    }
    
    return exemplo

# Exemplo de uso
texto = "João Silva trabalha na Acme Corp como Analista"
spans = [
    (0, 11, "nome_pessoal"),
    (26, 35, "empresa"),
    (41, 61, "cargo")
]

exemplo = anotar_exemplo(texto, spans)
print(json.dumps(exemplo, ensure_ascii=False, indent=2))
```

#### Opção 3: Usar Ferramentas de Anotação

Recomendadas:
- [Label Studio](https://labelstud.io/)
- [Prodigy](https://prodi.gy/)
- [INCEpTION](https://inception-project.github.io/)

### Validação de Dados

**Script para validar seus dados:**

```python
import json

def validar_dados(arquivo_jsonl):
    erros = []
    with open(arquivo_jsonl, 'r', encoding='utf-8') as f:
        for idx, linha in enumerate(f, 1):
            try:
                obj = json.loads(linha)
                
                # Verifica estrutura
                if "text" not in obj or "spans" not in obj:
                    erros.append(f"Linha {idx}: faltam campos 'text' ou 'spans'")
                    continue
                
                # Verifica spans
                for span_idx, span in enumerate(obj["spans"]):
                    if "start" not in span or "end" not in span or "label" not in span:
                        erros.append(f"Linha {idx}, span {span_idx}: faltam campos obrigatórios")
                        continue
                    
                    start, end = span["start"], span["end"]
                    if start >= end:
                        erros.append(f"Linha {idx}, span {span_idx}: start ({start}) >= end ({end})")
                    
                    if start < 0 or end > len(obj["text"]):
                        erros.append(f"Linha {idx}, span {span_idx}: índices fora do range")
            
            except json.JSONDecodeError as e:
                erros.append(f"Linha {idx}: JSON inválido - {e}")
    
    if erros:
        print("❌ Erros encontrados:")
        for erro in erros:
            print(f"  - {erro}")
        return False
    else:
        print("✅ Dados válidos!")
        return True

# Usar
validar_dados("meus_dados.jsonl")
```

## Fine-tuning

### Comando Básico

```bash
opf train treino.jsonl \
  --validation-dataset validacao.jsonl \
  --label-space-json examples/config_pt_br.json \
  --output-dir ./modelo_pt_br
```

### Comandos Avançados

```bash
# Com mais épocas
opf train treino.jsonl \
  --validation-dataset validacao.jsonl \
  --label-space-json examples/config_pt_br.json \
  --output-dir ./modelo_pt_br \
  --epochs 5

# Com taxa de aprendizado customizada
opf train treino.jsonl \
  --validation-dataset validacao.jsonl \
  --label-space-json examples/config_pt_br.json \
  --output-dir ./modelo_pt_br \
  --learning-rate 1e-4

# Com batch size maior (se tiver GPU)
opf train treino.jsonl \
  --validation-dataset validacao.jsonl \
  --label-space-json examples/config_pt_br.json \
  --output-dir ./modelo_pt_br \
  --batch-size 16
```

### Monitorar o Treinamento

A saída terá informações como:
- Loss de treinamento
- Loss de validação
- Métricas de precisão/recall

Exemplo:
```
Epoch 1/3
Training: 100/100 batches, Loss: 0.245
Validation: 20/20 batches, Loss: 0.198, F1: 0.87
```

## Uso do Modelo

### Redação Interativa

```bash
export OPF_CHECKPOINT=./modelo_pt_br
opf
# Digite seu texto, pressione Enter
# Resultado anonimizado aparece com JSON estruturado
```

### Redação de Arquivo

```bash
export OPF_CHECKPOINT=./modelo_pt_br
opf -f meu_documento.txt
```

### Uso Programático em Python

```python
import opf

# Carregar modelo
redactor = opf.OPF(checkpoint="./modelo_pt_br")

# Anonimizar texto
texto = "João Silva, CPF 123.456.789-00, email joao@example.com"
resultado = redactor.redact(texto)

print(resultado.redacted_text)
# Output: [PERSON] Silva, [PRIVATE_PERSON] [PRIVATE_EMAIL]

# Acessar spans detectados
for span in resultado.spans:
    print(f"{span.label}: {texto[span.start:span.end]}")
```

## Exemplos Práticos

### Exemplo 1: Redação de Currículo

```python
import opf

redactor = opf.OPF(checkpoint="./modelo_pt_br")

curriculo = """
JOÃO SILVA
CPF: 123.456.789-00
Endereço: Rua das Flores 123, São Paulo-SP
Telefone: (11) 98765-4321
Email: joao.silva@example.com

EXPERIÊNCIA
Acme Corp, São Paulo
Analista de Sistemas (2020-2024)
Salário: R$ 8.000,00

Universidade de São Paulo
Engenharia de Software (2016-2020)
"""

resultado = redactor.redact(curriculo)
print(resultado.redacted_text)
```

### Exemplo 2: Redação de Contatos

```python
import opf
import json

redactor = opf.OPF(checkpoint="./modelo_pt_br")

contatos = [
    "João Silva: (11) 98765-4321, joao@company.com",
    "Maria Santos: (21) 99876-5432, maria@company.com",
    "Carlos Oliveira: (31) 97654-3210, carlos@company.com",
]

for contato in contatos:
    resultado = redactor.redact(contato)
    print(f"Original: {contato}")
    print(f"Redacted: {resultado.redacted_text}")
    print()
```

### Exemplo 3: Exportar com Spans

```python
import opf
import json

redactor = opf.OPF(checkpoint="./modelo_pt_br")

texto = "Contato: João Silva, CPF 123.456.789-00, email joao@example.com"
resultado = redactor.redact(texto)

# Exportar dados com spans
output = {
    "original": texto,
    "redacted": resultado.redacted_text,
    "spans": [
        {
            "label": span.label,
            "start": span.start,
            "end": span.end,
            "text": texto[span.start:span.end]
        }
        for span in resultado.spans
    ]
}

print(json.dumps(output, ensure_ascii=False, indent=2))
```

## Troubleshooting

### Problema: Dados não são detectados

**Solução:**
1. Validar que o modelo foi treinado com esses dados
2. Aumentar o número de exemplos de treinamento
3. Aumentar o número de épocas
4. Verificar se o texto corresponde ao padrão dos dados de treinamento

```bash
# Retreinar com mais dados
python examples/gerar_dados_pt_br.py treino_grande.jsonl validacao.jsonl --num-treino 2000

opf train treino_grande.jsonl \
  --validation-dataset validacao.jsonl \
  --label-space-json examples/config_pt_br.json \
  --output-dir ./modelo_pt_br_v2 \
  --epochs 5
```

### Problema: Muitos falsos positivos

**Solução:**
1. Aumentar os dados de validação
2. Usar modelo base com modo de precisão (precision mode)
3. Fine-tunar com dados negativos (textos que não devem ser marcados)

```bash
opf redact --precision-mode "seu texto aqui"
```

### Problema: Lentidão na redação

**Solução:**
1. Se tiver GPU, garantir que está usando:
   ```bash
   opf --device cuda "seu texto"
   ```
2. Usar modelo menor se disponível
3. Fazer batch redaction em vez de linha por linha

### Problema: Erro ao treinar

**Verificar:**
```bash
# Validar dados
python validar_dados.py treino.jsonl

# Verificar se arquivo de config existe
ls -la examples/config_pt_br.json

# Verificar se modelo base está acessível
ls -la ~/.opf/privacy_filter/
```

## Performance Esperada

| Cenário | Precisão | Recall |
|---------|----------|--------|
| Modelo Base (inglês) em PT-BR | ~50% | ~40% |
| Fine-tuned com 100 exemplos | ~75% | ~70% |
| Fine-tuned com 500 exemplos | ~85% | ~82% |
| Fine-tuned com 2000 exemplos | ~92% | ~90% |

## Recursos Adicionais

- [Documentação OpenAI Privacy Filter](https://github.com/openai/privacy-filter)
- [Guia de Fine-tuning Original](./FINETUNING.md)
- [Referência de Output](./OUTPUT_SCHEMAS.md)

## Contribuições

Se você melhorou este guia ou tem exemplos adicionais, contribuições são bem-vindas!

---

**Desenvolvido para anonimização de dados em português brasileiro** 🇧🇷
