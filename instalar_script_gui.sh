#!/bin/bash

# Função para exibir caixa de diálogo de erro
show_error() {
    zenity --error --text="$1" --title="Erro"
}

# Função para exibir caixa de diálogo de informação
show_info() {
    zenity --info --text="$1" --title="Informação"
}

# Função para pedir confirmação
ask_confirmation() {
    zenity --question --text="$1" --title="Confirmação"
    return $?
}

# Definir os diretórios de instalação
SCRIPT_DIR="/opt"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/opt/icons"

# Mostrar a janela de boas-vindas
zenity --info --text="Este assistente irá mover o arquivo .sh para /opt, tornar o script executável, criar um atalho na área de aplicativos e associar um ícone ao aplicativo." --title="Assistente de Instalação"

# Seleciona o arquivo .sh
SCRIPT_PATH=$(zenity --file-selection --title="Selecione o arquivo .sh" --file-filter="*.sh")
if [ -z "$SCRIPT_PATH" ]; then
    show_error "Nenhum arquivo .sh selecionado!"
    exit 1
fi

# Solicitar ao usuário o ícone a ser associado
ICON_PATH=$(zenity --file-selection --title="Selecione o ícone" --file-filter="*.png *.jpg *.jpeg")
if [ -z "$ICON_PATH" ]; then
    show_error "Nenhum ícone selecionado!"
    exit 1
fi

# Perguntar se o usuário deseja continuar
ask_confirmation "Deseja continuar com a instalação do script selecionado?"
if [ $? -ne 0 ]; then
    show_info "Instalação cancelada."
    exit 0
fi

# Criar diretório para ícones em /opt, se não existir
sudo mkdir -p "$ICON_DIR"

# Definir o nome do arquivo e o novo caminho do script
SCRIPT_NAME=$(basename "$SCRIPT_PATH")
NEW_SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

# Mover o script para /opt
sudo mv "$SCRIPT_PATH" "$NEW_SCRIPT_PATH"
if [ $? -ne 0 ]; then
    show_error "Falha ao mover o script para $SCRIPT_DIR!"
    exit 1
fi

# Torna o arquivo script executável
sudo chmod +x "$NEW_SCRIPT_PATH"

# Mover o ícone para /opt/icons
ICON_NAME=$(basename "$ICON_PATH")
NEW_ICON_PATH="$ICON_DIR/$ICON_NAME"
sudo mv "$ICON_PATH" "$NEW_ICON_PATH"
if [ $? -ne 0 ]; then
    show_error "Falha ao mover o ícone para $ICON_DIR!"
    exit 1
fi

# Criar o arquivo .desktop
DESKTOP_FILE="$DESKTOP_DIR/$(basename "$SCRIPT_NAME" .sh).desktop"

# Informações básicas para o arquivo .desktop
APP_NAME=$(basename "$SCRIPT_NAME" .sh)
echo "[Desktop Entry]" | sudo tee "$DESKTOP_FILE" > /dev/null
echo "Name=$APP_NAME" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Exec=$NEW_SCRIPT_PATH" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Icon=$ICON_DIR/$ICON_NAME" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Terminal=true" | sudo tee -a "$DESKTOP_FILE" > /dev/null  # O script provavelmente será executado em um terminal
echo "Type=Application" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Categories=Utility;" | sudo tee -a "$DESKTOP_FILE" > /dev/null

# Atualiza as permissões do arquivo .desktop
sudo chmod +x "$DESKTOP_FILE"

# Confirmação de sucesso
show_info "O script foi movido para /opt, o ícone foi movido para /opt/icons e o atalho foi criado com sucesso em /usr/share/applications!"

