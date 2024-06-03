#!/bin/bash

# Toon het zelfbedieningsportaal voor VM-beheer
echo "Self-Service VM Management Portal"
echo "1) Start Environment"
echo "2) Stop Environment"
echo "3) Destroy Environment"
echo "4) Status of Environment"
echo "5) Create a New Environment"
echo "6) Adjust VM Memory"

# Vraag de gebruiker om een optie uit het menu te selecteren
read -p "Select an option: " option

# Functie om omgevingen te beheren
function manage_environment() {
    action=$1
    # Vraag de gebruiker om de naam van de omgeving in te voeren
    read -p "Enter the name of the environment (production, staging, test): " env_name
    env_path="environments/$env_name"
    # Controleer of de opgegeven omgeving bestaat
    if [[ -d "$env_path" ]]; then
        # Voer de Vagrant-actie uit in de opgegeven omgeving
        (cd "$env_path" && vagrant $action)
    else
        # Meld dat de opgegeven omgeving niet bestaat
        echo "Specified environment does not exist."
    fi
}

# Functie om het geheugen van een VM aan te passen
function adjust_vm_memory() {
    # Vraag de gebruiker om de benodigde gegevens in te voeren
    read -p "Enter the name of the environment (production, staging, test): " env_name
    read -p "Enter the name of the VM as specified in the Vagrantfile: " vm_name
    read -p "Enter the new memory size in MB (e.g., 2048): " new_memory_size
    env_path="environments/$env_name"
    # Controleer of de opgegeven omgeving bestaat
    if [[ -d "$env_path" ]]; then
        vagrantfile="$env_path/Vagrantfile"
        # Controleer of de VM-naam bestaat in het Vagrantfile en pas het geheugen aan
        if grep -q "$vm_name.vm.provider \"virtualbox\" do |v|" "$vagrantfile"; then
            sed -i "/$vm_name.vm.provider \"virtualbox\" do |v|/,/end/ s/v.memory = [0-9]\+/v.memory = $new_memory_size/" "$vagrantfile"
            echo "Memory of VM '$vm_name' in environment '$env_name' adjusted to $new_memory_size MB."
        else
            # Meld dat de opgegeven VM-naam niet gevonden is in het Vagrantfile
            echo "VM name '$vm_name' not found in the Vagrantfile."
        fi
    else
        # Meld dat de opgegeven omgeving niet bestaat
        echo "Specified environment '$env_name' does not exist."
    fi
}

# Verwerk de gebruikerskeuze
case $option in
    1)
        # Start de omgeving
        echo "Starting the environment..."
        manage_environment "up"
        ;;
    2)
        # Stop de omgeving
        echo "Stopping the environment..."
        manage_environment "halt"
        ;;
    3)
        # Vernietig de omgeving
        echo "Destroying the environment..."
        manage_environment "destroy -f"
        ;;
    4)
        # Geef de status van de omgeving weer
        echo "Getting the status of the environment..."
        manage_environment "status"
        ;;
    5)
        # Maak een nieuwe omgeving aan
        echo "Creating a new environment..."
        read -p "Enter the name of the new environment (production, staging, test): " env_name
        env_path="environments/$env_name"
        # Controleer of de nieuwe omgeving nog niet bestaat
        if [[ ! -d "$env_path" ]]; then
            cp -r template_env "$env_path"
            echo "Environment $env_name created. You can now use 'vagrant up' within the $env_name directory."
        else
            # Meld dat de omgeving al bestaat
            echo "Environment $env_name already exists."
        fi
        ;;
    6)
        # Pas het geheugen van een VM aan
        echo "Adjusting VM Memory..."
        adjust_vm_memory
        ;;
    *)
        # Meld een ongeldige optie
        echo "Invalid option selected."
        ;;
esac
