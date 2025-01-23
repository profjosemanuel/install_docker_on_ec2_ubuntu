#!/usr/bin/env bash

# Comprobar si el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse con privilegios de administrador."
    exit 1
fi

# Crear grupo "docker" si no existe
if ! getent group docker > /dev/null; then
    echo "Creando el grupo 'docker'..."
    groupadd docker
else
    echo "El grupo 'docker' ya existe."
fi

# Añadir el usuario actual al grupo "docker" si no está ya añadido
USER_NAME=$(whoami)
if ! id -nG "$USER_NAME" | grep -qw "docker"; then
    echo "Añadiendo el usuario '$USER_NAME' al grupo 'docker'..."
    usermod -aG docker "$USER_NAME"
else
    echo "El usuario '$USER_NAME' ya pertenece al grupo 'docker'."
fi

# Comprobar y aplicar cambios al grupo sin necesidad de cerrar sesión
newgrp docker

# Verificar la configuración
echo "Verificación: Usuario '$USER_NAME' pertenece a los grupos:"
id "$USER_NAME"

#Script para solo iniciar desde administrador
if ["$(id -u)" -ne 0]; then
        echo "Este script debe ejecutarse con privilegios de administrador."
        exit 1
fi

#Comprobante para añadir SOLO los repositorios que no estén instalados
if ! grep -q "https://download.docker.com/linux/ubuntu" /etc/apt/sources.list.d/docker.list 2>/dev/null; then
        echo "Añadiendo repositorio de Docker..."
	curl -fsSL https://dowload.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
else
	echo "El repositorio de Docker ya está añadido."
fi

#Verificar que los paquetes no se instales si ya están
if ! dpkg -l | grep -q docker-ce; then
	echo "Instalando Docker..."
	sudo apt install -y docker-ce docker-ce-cli containerd.io
else
	echo "Docker ya está instalado."
fi

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
