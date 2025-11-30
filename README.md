# ADMINISTRAÇÃO DE SISTEMAS
# Sistema de Backup Incremental com rsync

Este projeto é um sistema de backup incremental escrito em Bash, com suporte a configuração de diretórios, exclusões, logs e execução agendada via cron.

---

## Estrutura do Projeto

```
rsync-incremental-backup/
├── backup.sh
├── cleanup.sh
├── config/
│   ├── dirs.txt
│   ├── ignore.txt
│   └── destino.txt
└── logs/
    └── backup-YYYY-MM-DD.log
```

### Arquivos
- **backup.sh** — script principal
- **cleanup.sh** — script de exclusão de logs
- **config/dirs.txt** — lista de diretórios de origem
- **config/ignore.txt** — padrões excluídos do backup
- **config/destino.txt** — caminho do diretório de destino
- **logs/backup-YYYY-MM-DD.log** — logs diários

---

## Como usar

### 1. Permissão de execução
```sh
chmod +x backup.sh
chmod +x cleanup.sh
```

### 2. Executar o backup
```sh
./backup.sh
```

---

## Menu Principal

### Definir Destino do Backup
Configura onde os arquivos serão salvos. Os diretórios são salvos no arquivo config/destino.txt.

### Adicionar Pasta de Origem 
Adiciona diretórios a serem copiados nos backups. Os diretórios são salvos no arquivo config/dirs.txt.

### Executar Backup Agora
Realiza o backup imediatamente usando rsync.

### Agendar Backup (Cron)
Define uma regra cron, por exemplo:
```
*/10 * * * *   # a cada 10 minutos
0 2 * * *      # diariamente às 02:00
```
O script será chamado em modo não interativo através de:
```
backup.sh --cron
```

### Ver Logs
Mostra o log do backup do dia.

---

## Execução Não-Interativa

```sh
./backup.sh --cron
```
Usado pelo cron para execução automática sem exibir menu.

---

## Como Funciona (principais funções)

### `setup_ambiente()`
Cria diretórios e arquivos de configuração se não existirem.

### `executar_backup()`
Função principal do backup.sh: copia (sincroniza) os arquivos usando rsync.

### `log_msg()`
Padroniza logs e salva em `logs/backup-YYYY-MM-DD.log`.