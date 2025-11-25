# ADMINISTRAÇÃO DE SISTEMAS
# PROJETO1 – Sistema de Backup Incremental com rsync

## Como usar

1. (Obrigatório) Adicione os diretórios que deseja salvar em:
   config/dirs.txt

2. (Opcional) Adicione arquivos/pastas para ignorar em:
   config/ignore.txt

3. Execute o script backup para fazer o backup dos arquivos:
   chmod +x backup.sh
   ./backup.sh

4. O log ficará em:
   logs/backup-yyyy-MM-dd.log

5. Execute o script cleanup para remover os logs antigos:
   chmod +x cleanup.sh
   ./cleanup.sh