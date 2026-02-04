# vm-automation-via-glpi

Automatiser la création d’une VM Proxmox **à partir d’un template** via **Terraform**, piloté par un playbook **Ansible** (prévu pour être exécuté par **Semaphore**), typiquement déclenché depuis **GLPI** (formulaire / ticket / workflow).

Le projet contient :
- du Terraform pour cloner une VM dans Proxmox VE (provider `bpg/proxmox`),
- un playbook Ansible ([provision.yml](provision.yml)) qui exécute `terraform init/apply` et remonte les outputs (VM ID, IPv4).

## À quoi ça sert ?

But : **standardiser et industrialiser** la création de VMs (nom, node, CPU/RAM, bridge…) en déclenchant une exécution non-interactive (CI/runner Semaphore), sans se connecter manuellement à l’interface Proxmox.

Flux typique :
1. GLPI collecte les paramètres (nom VM, ressources, node, etc.).
2. Semaphore lance [provision.yml](provision.yml) sur un runner.
3. Le playbook exécute Terraform en local.
4. Terraform appelle l’API Proxmox et clone la VM depuis un template.
5. Les outputs Terraform sont renvoyés (ID VM, IP si disponible).

## Prérequis

- Proxmox VE accessible depuis la machine/runner qui exécute Terraform.
- Un **API Token** Proxmox avec les droits nécessaires (création/clone VM sur le node cible).
- Terraform (ou OpenTofu) installé sur le runner.
- Ansible installé si vous utilisez le playbook.
- Le template cloné doit idéalement avoir **QEMU Guest Agent** installé et actif (sinon l’IPv4 peut rester vide).

## Fichiers importants

- [main.tf](main.tf) : déclaration du provider requis (`bpg/proxmox`).
- [provider.tf](provider.tf) : configuration du provider Proxmox (URL + token).
- [variables.tf](variables.tf) : variables Proxmox + variables de la VM (nom, node, template, CPU, RAM, bridge).
- [cloner-vm.tf](cloner-vm.tf) : ressource `proxmox_virtual_environment_vm` (clone + agent + DHCP + NIC + CPU/RAM).
- [outpute.tf](outpute.tf) : outputs Terraform (`vm_id`, `vm_ipv4`, `vm_ipv4_addresses`).
- [variable.tfvars](variable.tfvars) : exemple de valeurs pour se connecter à Proxmox (à compléter).
- [provision.yml](provision.yml) : playbook Ansible (Semaphore/GLPI) qui exécute Terraform.

## Configuration

### 1) Renseigner la connexion Proxmox

Éditez [variable.tfvars](variable.tfvars) et remplacez les placeholders :
- `pm_api_url`
- `pm_api_token_id`
- `pm_api_token_secret`

Note : le playbook charge explicitement ce fichier via `-var-file=variable.tfvars`.

### 2) Paramètres VM (injectés par GLPI/Semaphore)

Le playbook accepte ces variables (avec valeurs par défaut) :
- `vm_name`
- `proxmox_node`
- `template_id`
- `vm_cpu`
- `vm_ram`
- `vm_bridge`

## Exécution

### Option A — Terraform en local

Depuis le dossier du projet :

```bash
terraform init
terraform plan -var-file=variable.tfvars
terraform apply -auto-approve -var-file=variable.tfvars \
	-var="vm_name=vm-demo" \
	-var="proxmox_node=A51" \
	-var="template_id=301" \
	-var="vm_cpu=2" \
	-var="vm_ram=4096" \
	-var="vm_bridge=vmbr0"
```

Récupérer les outputs :

```bash
terraform output
terraform output -json
```

### Option B — Via Ansible (Semaphore)

Exécution manuelle possible :

```bash
ansible-playbook provision.yml \
	-e vm_name=vm-demo \
	-e proxmox_node=A51 \
	-e template_id=301 \
	-e vm_cpu=2 \
	-e vm_ram=4096 \
	-e vm_bridge=vmbr0
```

Le playbook affiche ensuite un résumé avec `VM ID` et `IPv4` (si remontée par l’agent).

## Outputs

- `vm_id` : ID Proxmox de la VM créée.
- `vm_ipv4` : première IPv4 détectée (peut être `null` si DHCP/agent pas prêt).
- `vm_ipv4_addresses` : liste complète des IPv4 détectées.

## Notes / Dépannage

- **IPv4 vide** : vérifiez que le template a `qemu-guest-agent` installé et démarré, et que l’option agent est activée (elle l’est dans Terraform).
- **Variables Proxmox manquantes** : assurez-vous que `-var-file=variable.tfvars` est bien pris en compte (déjà présent dans le playbook).
- **Sécurité** : ne stockez pas de secrets en clair dans Git. Idéalement, injectez `pm_api_token_secret` via les secrets Semaphore/GLPI et gardez un fichier tfvars local non versionné.