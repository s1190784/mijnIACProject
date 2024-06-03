#!/bin/bash

# Definieer de basispaden
PROJECT_DIR=~/mijnIACProject/environments/test
KEYS_DIR=$PROJECT_DIR/ssh_keys
ADMIN_KEYS_DIR=$KEYS_DIR/admin
CUSTOMER_KEYS_DIR_PREFIX=$KEYS_DIR/customer

# Maak de directories aan als ze niet bestaan
mkdir -p "$ADMIN_KEYS_DIR"
for customer_id in 1 2; do
  mkdir -p "${CUSTOMER_KEYS_DIR_PREFIX}${customer_id}"
done

# Functie om SSH-sleutelparen te genereren
generate_key_pair() {
  vm_name=$1
  key_path=$2
  
  # Controleer of de sleutels al bestaan, zo niet, genereer ze
  if [ ! -f "${key_path}" ]; then
    echo "Genereren van SSH-sleutelpaar voor $vm_name..."
    ssh-keygen -t rsa -b 2048 -f "${key_path}" -N ''
    echo "Sleutelpaar gegenereerd: ${key_path}"
  else
    echo "Sleutelpaar bestaat al: ${key_path}"
  fi
}

# VM-namen voor beheerders
admin_vms=("webtest1" "webtest2" "lbtest" "dbtest")

# VM-namen voor klanten
customer_vms=("webtest1" "webtest2" "lbtest" "dbtest")

# Genereer sleutelparen voor beheerders
for vm_name in "${admin_vms[@]}"; do
  key_path="${ADMIN_KEYS_DIR}/${vm_name}_server_admin"
  generate_key_pair "$vm_name" "$key_path"
done

# Genereer sleutelparen voor elke VM voor elke klant
for customer_id in 1 2; do
  for vm_name in "${customer_vms[@]}"; do
    key_path="${CUSTOMER_KEYS_DIR_PREFIX}${customer_id}/${vm_name}_server_customer${customer_id}"
    generate_key_pair "$vm_name" "$key_path"
  done
done

echo "SSH-sleutelparen generatie voltooid."

