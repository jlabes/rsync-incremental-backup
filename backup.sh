#!/bin/bash

# --- CONFIGURAÇÕES E VARIÁVEIS GLOBAIS ---

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="$BASE_DIR/config"
DIRS_FILE="$CONFIG_DIR/dirs.txt" 
IGNORE_FILE="$CONFIG_DIR/ignore.txt"
DESTINO_CFG="$CONFIG_DIR/destino.txt"

LOG_DIR="$BASE_DIR/logs"
DATA_ATUAL=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/backup-$DATA_ATUAL.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- FUNÇÕES AUXILIARES ---

setup_ambiente() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"

    [ ! -f "$DIRS_FILE" ] && touch "$DIRS_FILE"
    [ ! -f "$IGNORE_FILE" ] && touch "$IGNORE_FILE"
    [ ! -f "$DESTINO_CFG" ] && touch "$DESTINO_CFG"
}

log_msg() {
    local nivel="$1"
    local mensagem="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] [$nivel] $mensagem" >> "$LOG_FILE"

    if [ -t 1 ]; then
        case $nivel in
            "INFO") echo -e "${BLUE}[INFO]${NC} $mensagem" ;;
            "SUCCESS") echo -e "${GREEN}[OK]${NC} $mensagem" ;;
            "WARN") echo -e "${YELLOW}[ALERTA]${NC} $mensagem" ;;
            "ERROR") echo -e "${RED}[ERRO]${NC} $mensagem" ;;
        esac
    fi
}

# --- FUNÇÕES DE CONFIGURAÇÃO ---

configurar_destino() {
    echo -e "\n--- Configurar Local de Destino do Backup ---"
   
    if [ -s "$DESTINO_CFG" ]; then
        atual=$(cat "$DESTINO_CFG")
        echo -e "Destino atual configurado: ${YELLOW}$atual${NC}"
    fi

    echo "Digite o caminho completo onde os backups serão salvos:"
    echo "(Ex: /home/usuario/backups)"
    read -r novo_destino

    if [ -z "$novo_destino" ]; then
        echo "Operação cancelada. Caminho vazio."
        return
    fi

    if mkdir -p "$novo_destino"; then
        echo "$novo_destino" > "$DESTINO_CFG"
        log_msg "SUCCESS" "Novo local de backup definido: $novo_destino"
    else
        log_msg "ERROR" "Não foi possível criar ou acessar: $novo_destino"
    fi
}

adicionar_origem() {
    echo -e "\n--- Adicionar Pasta para Fazer Backup ---"
    echo "Digite o caminho da pasta que você quer salvar:"
    read -r caminho_origem

    if [ ! -d "$caminho_origem" ]; then
        log_msg "ERROR" "A pasta '$caminho_origem' não existe."
        return
    fi

    if grep -Fxq "$caminho_origem" "$DIRS_FILE"; then
        log_msg "WARN" "Essa pasta já está na lista."
    else
        echo "$caminho_origem" >> "$DIRS_FILE"
        log_msg "SUCCESS" "Pasta adicionada: $caminho_origem"
    fi
}

# --- LÓGICA DO BACKUP (Execução) ---

executar_backup() {
    log_msg "INFO" ">>> Iniciando rotina de backup..."

    if [ ! -s "$DESTINO_CFG" ]; then
        log_msg "ERROR" "Destino de backup não configurado! Configure pelo menu primeiro."
        return
    fi

    local destino_root
    destino_root=$(head -n 1 "$DESTINO_CFG")

    if [ ! -d "$destino_root" ]; then
        log_msg "ERROR" "O diretório de destino não está acessível: $destino_root"
        return
    fi

    # Validação: O usuário configurou o que salvou
    if [ ! -s "$DIRS_FILE" ]; then
        log_msg "WARN" "Nenhuma pasta configurada para backup em $DIRS_FILE."
        return
    fi

    while IFS= read -r origem || [ -n "$origem" ]; do
        [ -z "$origem" ] && continue

        if [ -d "$origem" ]; then
	  
	    destino_final="$destino_root"

            log_msg "INFO" "Sincronizando: $origem -> $destino_final"

            
            rsync -av --exclude="ignore.txt" --exclude-from="$IGNORE_FILE" "$origem/" "$destino_final" >> "$LOG_FILE" 2>&1
            
            if [ $? -eq 0 ]; then
                log_msg "SUCCESS" "Backup de '$origem' OK."
            else
                log_msg "ERROR" "Falha no rsync de '$origem'."
            fi
        else
            log_msg "WARN" "Pasta de origem sumiu: $origem"
        fi
    done < "$DIRS_FILE"
    
    log_msg "INFO" ">>> Fim da rotina."
}

# --- MENU RECURSIVO ---

exibir_menu() {
    echo -e "\n=========================================="
    echo -e "      SISTEMA DE BACKUP     "
    echo -e "=========================================="
    
 
    if [ -s "$DESTINO_CFG" ]; then
        dest=$(head -n 1 "$DESTINO_CFG")
        echo -e "Destino Atual: ${GREEN}$dest${NC}"
    else
        echo -e "Destino Atual: ${RED}NÃO CONFIGURADO${NC}"
    fi
    echo -e "------------------------------------------"
    echo "1. Definir ou Editar onde salvar os backups (Destino)"
    echo "2. Adicionar pasta para salvar (Origem)"
    echo "3. Executar backup agora"
    echo "4. Executar backup agendado"
    echo "5. Ver logs"
    echo "0. Sair"
    echo -n "Opção: "
    read opcao

    case $opcao in
        1)
            configurar_destino
            exibir_menu
            ;;
        2)
            adicionar_origem
            sleep 1
            exibir_menu
            ;;
        3)
            executar_backup
            echo "Pressione ENTER para voltar..."
            read
            exibir_menu
            ;;

	 4)
 
           echo -e "\n--- Agendar Backup Automático (Cron) ---"
           echo "Digite a frequência no formato Cron (Ex: '*/5 * * * *' para cada 5 min)"
           echo -n "Frequência: "
           read tempo_agendado
            
           if [ -z "$tempo_agendado" ]; then
                echo "Agendamento cancelado."
           else

                SCRIPT_PATH="$BASE_DIR/backup.sh"
                
                # Monta a linha do cron
                NOVA_LINHA="$tempo_agendado $SCRIPT_PATH --cron"
                
                crontab <<< "$NOVA_LINHA"

		echo
                
                if [ $? -eq 0 ]; then
                    log_msg "SUCCESS" "Agendamento criado: $NOVA_LINHA"
                else
                    log_msg "ERROR" "Falha ao criar agendamento no Cron."
                fi
            fi
           
           echo "Pressione ENTER para voltar..."
           read
           exibir_menu
           ;;


        5)
            [ -f "$LOG_FILE" ] && cat "$LOG_FILE" || echo "Sem logs."
            read -p "Enter para voltar..."
            exibir_menu
            ;;
        0)
            log_msg "INFO" "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida."
            sleep 1
            exibir_menu
            ;;
    esac
}

# --- INÍCIO ---

setup_ambiente

if [ "${1:-}" == "--cron" ]; then
    executar_backup
else
    exibir_menu
fi
