#!/bin/bash

# Definieer de basispaden
PROJECT_DIR=~/mijnIACProject/environments/production
KEYS_DIR=$PROJECT_DIR/ssh_keys

# Maak de ssh_keys directory als deze niet bestaat
mkdir -p "$KEYS_DIR"

# Functie om SSH-sleutelparen te genereren
generate_key_pair() {
  vm_name=$1
  key_path="$KEYS_DIR/${vm_name}_server"

  # Controleer of de sleutels al bestaan, zo niet, genereer ze
  if [ ! -f "${key_path}" ]; then
    echo "Genereren van SSH-sleutelpaar voor $vm_name..."
    ssh-keygen -t rsa -b 2048 -f "${key_path}" -N ''
    echo "Sleutelpaar gegenereerd: ${key_path}"
  else
    echo "Sleutelpaar bestaat al: ${key_path}"
  fi
}

# Genereer sleutelparen voor elke VM
generate_key_pair "web1_2"
generate_key_pair "web2_2"
generate_key_pair "lb_2"
generate_key_pair "db_2"

echo "SSH-sleutelparen generatie voltooid."
