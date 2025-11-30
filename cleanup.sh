#!/bin/bash

LOG_DIR="./logs"
DAYS=7

# Procura dentro da pasta ./logs
# por arquivos .log
# cujo tempo de modificação seja superior a 7 dias
# e remove esses arquivos automaticamente
find "$LOG_DIR" -type f -mtime +$DAYS -name "*.log" -delete