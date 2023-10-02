# Secrets Generator
The secrets generator provisions secrets, configured in a local file to a 1Password Vault.

The Makefile can create and delete 1Password Vaults.

## Requirements
* [1Password](https://1password.com)
* [1Password CLI](https://developer.1password.com/docs/cli/)
* python3

# Usage
## provision
```zsh
make vault
#	create vault
#	prepare vault secrets config for provisioning
#	initialize vault with example secrets
```

## push secrets to vault
```zsh
make vault-secrets
```

## deprovision
```zsh
make vault-delete
```