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

# Definir o diretório de instalação do AppImage
APPIMAGE_DIR="/opt"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/opt/icons"

# Mostrar a janela de boas-vindas
zenity --info --text="Este assistente irá mover o AppImage para /opt, criar um atalho na área de aplicativos e associar um ícone ao aplicativo." --title="Assistente de Instalação"

# Seleciona o arquivo AppImage
APPIMAGE_PATH=$(zenity --file-selection --title="Selecione o arquivo AppImage" --file-filter="*.AppImage")
if [ -z "$APPIMAGE_PATH" ]; then
    show_error "Nenhum arquivo AppImage selecionado!"
    exit 1
fi

# Solicitar ao usuário o ícone a ser associado
ICON_PATH=$(zenity --file-selection --title="Selecione o ícone" --file-filter="*.png *.jpg *.jpeg")
if [ -z "$ICON_PATH" ]; then
    show_error "Nenhum ícone selecionado!"
    exit 1
fi

# Perguntar se o usuário deseja continuar
ask_confirmation "Deseja continuar com a instalação do AppImage selecionado?"
if [ $? -ne 0 ]; then
    show_info "Instalação cancelada."
    exit 0
fi

# Criar diretório para ícones em /opt, se não existir
sudo mkdir -p "$ICON_DIR"

# Definir o nome do arquivo e o novo caminho do AppImage
APPIMAGE_NAME=$(basename "$APPIMAGE_PATH")
NEW_APPIMAGE_PATH="$APPIMAGE_DIR/$APPIMAGE_NAME"

# Mover o AppImage para /opt
sudo mv "$APPIMAGE_PATH" "$NEW_APPIMAGE_PATH"
if [ $? -ne 0 ]; then
    show_error "Falha ao mover o AppImage para $APPIMAGE_DIR!"
    exit 1
fi

# Torna o arquivo AppImage executável
sudo chmod +x "$NEW_APPIMAGE_PATH"

# Mover o ícone para /opt/icons
ICON_NAME=$(basename "$ICON_PATH")
NEW_ICON_PATH="$ICON_DIR/$ICON_NAME"
sudo mv "$ICON_PATH" "$NEW_ICON_PATH"
if [ $? -ne 0 ]; then
    show_error "Falha ao mover o ícone para $ICON_DIR!"
    exit 1
fi

# Criar o arquivo .desktop
DESKTOP_FILE="$DESKTOP_DIR/$(basename "$APPIMAGE_NAME" .AppImage).desktop"

# Informações básicas para o arquivo .desktop
APP_NAME=$(basename "$APPIMAGE_NAME" .AppImage)
echo "[Desktop Entry]" | sudo tee "$DESKTOP_FILE" > /dev/null
echo "Name=$APP_NAME" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Exec=$NEW_APPIMAGE_PATH" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Icon=$ICON_DIR/$ICON_NAME" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Terminal=false" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Type=Application" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Categories=Utility;" | sudo tee -a "$DESKTOP_FILE" > /dev/null

# Atualiza as permissões do arquivo .desktop
sudo chmod +x "$DESKTOP_FILE"

# Confirmação de sucesso
show_info "O AppImage foi movido para /opt, o ícone foi movido para /opt/icons e o atalho foi criado com sucesso em /usr/share/applications!"

