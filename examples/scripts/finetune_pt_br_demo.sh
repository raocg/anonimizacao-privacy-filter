#!/bin/bash
# Portuguese Brazilian Privacy Filter Training Example
# Este script demonstra como treinar um modelo com dados em português brasileiro

set -e

# Check for required arguments
if [ -z "$1" ]; then
    echo "Uso: $0 <caminho_do_checkpoint_base>"
    echo ""
    echo "Exemplo:"
    echo "  $0 ~/.opf/privacy_filter"
    echo ""
    echo "Este script treina um modelo com dados em português brasileiro."
    exit 1
fi

BASE_CHECKPOINT="$1"
WORKDIR="${2:-./_trabalho_pt_br}"
OUTPUT_CHECKPOINT="${WORKDIR}/modelo_pt_br"

# Criar diretórios
mkdir -p "${WORKDIR}"
mkdir -p "${WORKDIR}/dados"

echo "🇧🇷 Preparando treinamento do Privacy Filter para português brasileiro..."
echo ""
echo "Checkpoint base: ${BASE_CHECKPOINT}"
echo "Diretório de trabalho: ${WORKDIR}"
echo "Modelo de saída: ${OUTPUT_CHECKPOINT}"
echo ""

# Criar arquivo de dados de treinamento de exemplo (JSONL)
echo "📝 Criando dados de treinamento em português..."
cat > "${WORKDIR}/dados/treino_pt_br.jsonl" << 'EOF'
{"text": "Meu nome é João Silva e meu CPF é 123.456.789-00, resido em São Paulo-SP.", "spans": [{"start": 11, "end": 22, "label": "nome_pessoal"}, {"start": 39, "end": 56, "label": "cpf"}, {"start": 68, "end": 81, "label": "endereco_pessoal"}]}
{"text": "Meu email é joao.silva@example.com e meu telefone é (11) 98765-4321", "spans": [{"start": 11, "end": 31, "label": "email_pessoal"}, {"start": 51, "end": 67, "label": "telefone_pessoal"}]}
{"text": "Trabalho na empresa Acme Corp como Analista de Sistemas, ganhando R$ 5.000,00 mensais.", "spans": [{"start": 19, "end": 28, "label": "empresa"}, {"start": 34, "end": 54, "label": "cargo"}, {"start": 68, "end": 77, "label": "salario"}]}
{"text": "Meu RG é 12.345.678-9 e minha CNH é 1234567890", "spans": [{"start": 10, "end": 21, "label": "rg"}, {"start": 34, "end": 44, "label": "cnh"}]}
{"text": "Número da minha conta bancária: 123456-7 da agência 1234", "spans": [{"start": 30, "end": 37, "label": "numero_conta"}, {"start": 50, "end": 54, "label": "numero_agencia"}]}
{"text": "Meu CNPJ é 12.345.678/0001-90 e minha data de nascimento é 01/05/1990.", "spans": [{"start": 10, "end": 28, "label": "cnpj"}, {"start": 57, "end": 67, "label": "data_nascimento"}]}
{"text": "Minha mãe chama-se Maria Santos e residimos juntas em São Paulo.", "spans": [{"start": 19, "end": 32, "label": "nome_mae"}, {"start": 50, "end": 62, "label": "endereco_pessoal"}]}
{"text": "Meu número de cartão de crédito é 1234-5678-9012-3456, a data de validade é 12/25.", "spans": [{"start": 33, "end": 53, "label": "numero_cartao"}, {"start": 72, "end": 77, "label": "data_pessoal"}]}
EOF

# Criar arquivo de dados de validação (JSONL)
echo "📝 Criando dados de validação em português..."
cat > "${WORKDIR}/dados/validacao_pt_br.jsonl" << 'EOF'
{"text": "Contato do cliente: Carlos Oliveira, CPF 987.654.321-00, endereço Rua das Flores 123, Rio de Janeiro-RJ, telefone (21) 99999-8888", "spans": [{"start": 20, "end": 35, "label": "nome_pessoal"}, {"start": 42, "end": 59, "label": "cpf"}, {"start": 70, "end": 104, "label": "endereco_pessoal"}, {"start": 115, "end": 131, "label": "telefone_pessoal"}]}
{"text": "Processo número 0001234-56.2024.8.26.0100 referente a ação trabalhista", "spans": [{"start": 18, "end": 42, "label": "numero_processo_legal"}]}
EOF

# Copiar arquivo de configuração de labels
echo "⚙️  Copiando arquivo de configuração de labels..."
cp examples/config_pt_br.json "${WORKDIR}/dados/"

# Executar treinamento
echo ""
echo "🚀 Iniciando treinamento do modelo..."
echo ""

opf train "${WORKDIR}/dados/treino_pt_br.jsonl" \
  --validation-dataset "${WORKDIR}/dados/validacao_pt_br.jsonl" \
  --label-space-json "${WORKDIR}/dados/config_pt_br.json" \
  --output-dir "${OUTPUT_CHECKPOINT}" \
  --epochs 3

echo ""
echo "✅ Treinamento concluído com sucesso!"
echo ""
echo "📂 Modelo salvo em: ${OUTPUT_CHECKPOINT}"
echo ""
echo "Para usar o modelo treinado:"
echo "  export OPF_CHECKPOINT=${OUTPUT_CHECKPOINT}"
echo "  opf 'Seu texto em português aqui'"
echo ""
