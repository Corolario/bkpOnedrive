# Backup Frigate → OneDrive via rclone

Faz backup automático das gravações do Frigate para duas contas OneDrive (1 TB cada), alternando por paridade do dia.

## Pré-requisitos

- `rclone` instalado e configurado com dois remotes:
  - **`diasPares`** — conta OneDrive para dias pares (2, 4, 6…)
  - **`diaImpar`** — conta OneDrive para dias ímpares (1, 3, 5…)

### Configurar os remotes

```bash
rclone config
# Siga o assistente para criar um remote "diasPares" (OneDrive)
# Repita para criar o remote "diaImpar"
```

Confirme os remotes criados:

```bash
rclone listremotes
```

## Instalação

```bash
# 1. Clone o repositório
git clone <url> /home/user/bkpOnedrive

# 2. Torne o script executável
chmod +x /home/user/bkpOnedrive/backup-onedrive.sh

# 3. Instale o cron (como root)
cp /home/user/bkpOnedrive/cron.d/bkp-onedrive /etc/cron.d/bkp-onedrive
chmod 644 /etc/cron.d/bkp-onedrive
```

## Estrutura esperada

```
/home/usua1/frigate/storage/recordings/
├── 2026-04-22/   ← dia par  → diasPares
├── 2026-04-23/   ← dia ímpar → diaImpar
└── 2026-04-24/   ← dia par  → diasPares
```

O script roda às **00:10** e envia o diretório do **dia anterior** para o remote correspondente.

## Logs

Os logs ficam em `/var/log/bkp-onedrive/backup-YYYY-MM-DD.log`.

## Teste manual

```bash
# Simular sem transferir arquivos (dry-run)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
rclone copy /home/usua1/frigate/storage/recordings/${YESTERDAY} diasPares:recordings/${YESTERDAY} --dry-run

# Executar o script diretamente
sudo /home/user/bkpOnedrive/backup-onedrive.sh
```
