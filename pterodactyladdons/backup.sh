#!/bin/bash

set -e

########################################################
# 
#         Pterodactyl-AutoAddons Installation
#
#         Created and maintained by Ferks-FK
#
#            Protected by GPL 3.0 License
#
########################################################

#### Fixed Variables ####

SUPPORT_LINK="https://discord.gg/CUNEGx2Jaq"

#### Update Variables ####

update_variables() {
INFORMATIONS="/var/log/Pterodactyl-AutoAddons-informations"
MORE_BUTTONS="${PTERO}/resources/scripts/components/server/MoreButtons.tsx"
PMA_ARCH="${PTERO}/resources/scripts/routers/ServerRouter.tsx"
PMA_FILE="${PTERO}/resources/scripts/components/server/databases/DatabaseRow.tsx"
PMA_REDIRECT_FILE="${PTERO}/public/pma_redirect.html"
PMA_NAME="${PTERO}/public/phpmyadmin"
if [ -f "${INFORMATIONS}/user.txt" ]; then
  USERNAME="$(cat "${INFORMATIONS}/user.txt")"
fi
if [ -f "${INFORMATIONS}/pass.txt" ]; then
  PASSWORD="$(cat "${INFORMATIONS}/pass.txt")"
fi
if [ -f "${INFORMATIONS}/check_variable.txt" ]; then
  GET_INFO="$(cat "${INFORMATIONS}/check_variable.txt")"
fi
MC_PASTE="${PTERO}/app/Repositories/Eloquent/MCPasteVariableRepository.php"
FILES_IN_EDITOR="${PTERO}/resources/scripts/components/server/files/FileViewer.tsx"
}


print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

print_warning() {
  YELLOW="\033[1;33m"
  red='\033[0;31m'
  echo -e "* ${YELLOW}WARNING${reset}: $1"
  echo ""
}


hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}


#### Colors ####

GREEN="\e[0;92m"
YELLOW="\033[1;33m"
reset="\e[0m"
red='\033[0;31m'


#### Find where pterodactyl is installed ####

find_pterodactyl() {
echo
print_brake 47
echo -e "* ${GREEN}Looking for your pterodactyl installation...${reset}"
print_brake 47
echo
sleep 2
if [ -d "/var/www/pterodactyl" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/pterodactyl"
  elif [ -d "/var/www/panel" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/panel"
  elif [ -d "/var/www/ptero" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/ptero"
  elif [ -d "/app" ]; then
    PTERO_INSTALL=true
    PTERO="/app"
  else
    PTERO_INSTALL=false
fi
# Update the variables after detection of the pterodactyl installation #
update_variables
}

#### Deletes all files installed by the script ####

delete_files() {
#### ADDON MORE_BUTONS ####
if [ -f "$MORE_BUTTONS" ]; then
  rm -r "$MORE_BUTTONS"
fi
#### ADDON MORE_BUTONS ####

#### ADDON PMA_BUTTON_NAVBAR ####
if grep "<a href='/phpmyadmin' target='_blank'>PhpMyAdmin</a>" "$PMA_ARCH" &>/dev/null; then
  rm -r "$PMA_NAME"
  rm -r /etc/phpmyadmin
  if [ "$GET_INFO" == true ]; then
    if [ -f "$INFORMATIONS/user.txt" ]; then
      mysql -u root -p"$PASSWORD" -e "DROP USER '${USERNAME}'@'%';"
      rm -r "$INFORMATIONS/user.txt"
    fi
      mysql -u root -p"$PASSWORD" -e "DROP USER 'pma'@'127.0.0.1';"
      mysql -u root -p"$PASSWORD" -e "DROP DATABASE phpmyadmin;"
    elif [ "$GET_INFO" == false ]; then
      if [ -f "$INFORMATIONS/user.txt" ]; then
        mysql -u root -e "DROP USER '${USERNAME}'@'%';"
        rm -r "$INFORMATIONS/user.txt"
      fi
        mysql -u root -e "DROP USER 'pma'@'127.0.0.1';"
        mysql -u root -e "DROP DATABASE phpmyadmin;"
  fi
  rm -r "$INFORMATIONS"
fi
#### ADDON PMA_BUTTON_NAVBAR ####

#### ADDON PMA_BUTTON_DATABASE_TAB ####
if grep 'location.replace("/pma_redirect.html");' "$PMA_FILE" &>/dev/null; then
  rm -r "$PMA_NAME" "$PMA_REDIRECT_FILE"
  rm -r /etc/phpmyadmin
  if [ "$GET_INFO" == true ]; then
    if [ -f "$INFORMATIONS/user.txt" ]; then
      mysql -u root -p"$PASSWORD" -e "DROP USER '${USERNAME}'@'%';"
      rm -r "$INFORMATIONS/user.txt"
    fi
      mysql -u root -p"$PASSWORD" -e "DROP USER 'pma'@'127.0.0.1';"
      mysql -u root -p"$PASSWORD" -e "DROP DATABASE phpmyadmin;"
    elif [ "$GET_INFO" == false ]; then
      if [ -f "$INFORMATIONS/user.txt" ]; then
        mysql -u root -e "DROP USER '${USERNAME}'@'%';"
        rm -r "$INFORMATIONS/user.txt"
      fi
        mysql -u root -e "DROP USER 'pma'@'127.0.0.1';"
        mysql -u root -e "DROP DATABASE phpmyadmin;"
  fi
  rm -r "$INFORMATIONS"
fi
#### ADDON PMA_BUTTON_DATABASE_TAB ####

#### ADDON MC_PASTE ####
if [ -f "$MC_PASTE" ]; then
  rm -r "$MC_PASTE"
  rm -r "$PTERO/app/Http/Controllers/Admin/MCPasteController.php"
  rm -r "$PTERO/app/Http/Controllers/Api/Client/Servers/MCPasteController.php"
  rm -r "$PTERO/app/Http/Requests/Admin/MCPasteFormRequest.php"
  rm -r "$PTERO/app/Http/Requests/Api/Client/Servers/ShareLogRequest.php"
  rm -r "$PTERO/app/Models/MCPasteVariable.php"
  rm -r "$PTERO/patches"
  rm -r "$PTERO/resources/scripts/api/server/shareServerLog.ts"
  rm -r "$PTERO/resources/scripts/components/server/McPaste.tsx"
  rm -r "$PTERO/resources/views/admin/mcpaste"
  if [ "$GET_INFO" == true ]; then
      mysql -u root -p"$PASSWORD" -e "USE panel;DROP TABLE mcpaste_variables;"
    elif [ "$GET_INFO" == false ]; then
      mysql -u root -e "USE panel;DROP TABLE mcpaste_variables;"
  fi
  rm -r "$INFORMATIONS"
fi
#### ADDON MC_PASTE ####

#### ADDON FILES_IN_EDITOR
if [ -f "$FILES_IN_EDITOR" ]; then
  rm -r "$FILES_IN_EDITOR"
fi
#### ADDON FILES_IN_EDITOR
}

#### Restore Backup ####

restore() {
echo
print_brake 35
echo -e "* ${GREEN}Checking for a backup...${reset}"
print_brake 35
echo
if [ -d "$PTERO/PanelBackup[Auto-Addons]" ]; then
    cd "$PTERO/PanelBackup[Auto-Addons]"
    tar -xzvf "PanelBackup[Auto-Addons].tar.gz"
    rm -R "PanelBackup[Auto-Addons].tar.gz"
    cp -r -- * .env "$PTERO"
    rm -r "$PTERO/PanelBackup[Auto-Addons]"
  else
    print_brake 45
    echo -e "* ${red}There was no backup to restore, Aborting...${reset}"
    print_brake 45
    echo
    exit 1
fi
}
 
bye() {
print_brake 50
echo
echo -e "* ${GREEN}Backup restored successfully!"
echo -e "* Thank you for using this script."
echo -e "* Support group: ${YELLOW}$(hyperlink "$SUPPORT_LINK")${reset}"
echo
print_brake 50
}

#### Define Permissions ####

permissions() {
if id "www-data" &>/dev/null; then
    chown -R www-data:www-data "$PTERO"/*
  elif id "nginx" &>/dev/null; then
    chown -R nginx:nginx "$PTERO"/*
  elif id "apache" &>/dev/null; then
    chown -R apache:apache "$PTERO"/*
  else
    print_warning "The correct permissions could not be set. Contact the script author."
fi
}


#### Exec Script ####
find_pterodactyl
if [ "$PTERO_INSTALL" == true ]; then
    echo
    print_brake 60
    echo -e "* ${GREEN}Installation of the panel found, continuing the backup...${reset}"
    print_brake 60
    echo
    delete_files
    restore
    permissions
    bye
  elif [ "$PTERO_INSTALL" == false ]; then
    echo
    print_brake 66
    echo -e "* ${red}The installation of your panel could not be located, aborting...${reset}"
    print_brake 66
    echo
    exit 1
fi
