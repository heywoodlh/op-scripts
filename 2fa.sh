#!/usr/bin/env bash

check_os () {
	if uname -a | grep -iq 'linux'
	then
		OS='Linux'
	elif uname -a | grep -iq 'darwin'
	then
		OS='Mac'
	else
		echo "Unsupported platform. Exiting."
		exit 1
	fi
	if [[ "$OS" == 'Linux' ]]
	then
		return 5
	elif [[ "$OS" == 'Mac' ]]
	then
		return 10
	fi
}

check_deps () {
	OS="$1"
	if [[ "$OS" == 'Linux' ]]
	then
		PACKAGES=(bw xclip rofi jq zenity)
	elif [[ "$OS" == 'Mac' ]]
	then
		PACKAGES=(bw choose jq)
	fi
	FAILED_PACKAGES=()
	FAILURE='FALSE'
	for PACKAGE in "${PACKAGES[@]}"
	do
		command -v "$PACKAGE" >/dev/null 2>&1 || FAILURE='TRUE' && FAILED_PACKAGES+=("$PACKAGE")
	done

	if  [ "$FAILURE" == 'TRUE' ]
	then
		echo "Please install ${PACKAGES[*]}"
		exit 1
	fi
}


bw_get_items () {
	OS="$1"
	if [ ! -f ~/.bw_session ]
	then
		if [[ "$OS" == 'Mac' ]]
		then
			VAULT_PW="$(osascript -e 'Tell application "System Events" to display dialog "Enter Bitwarden Vault Password:" with hidden answer default answer ""' -e 'text returned of result' 2>/dev/null)"
		elif [[ "$OS" == 'Linux' ]]
		then
			VAULT_PW="$(zenity --password)"
		fi
		BW_SESSION="$(bw unlock "$VAULT_PW" --raw)"
		echo "$BW_SESSION" > ~/.bw_session
	else
		BW_SESSION="$(cat ~/.bw_session)"
	fi

	if [[ "$OS" == 'Linux' ]]
	then
		SELECTION="$(bw list items --session "$BW_SESSION" | jq -r '.[] | select(.login.totp != null) | .name' | rofi -dmenu -p 'MFA: ')"
		bw get totp "$SELECTION" --session "$BW_SESSION" | xclip -selection clipboard
	elif [[ "$OS" == 'Mac' ]]
	then
		SELECTION="$(bw list items --session "$BW_SESSION" | jq -r '.[] | select(.login.totp != null) | .name' | choose)"
		bw get totp "$SELECTION" --session "$BW_SESSION" | pbcopy
	fi
	
}	


main () {
	check_os
	RETURN="$?"
	if [[ "$RETURN" == 5 ]]
	then
		OS='Linux'
	elif [[ "$RETURN" == 10 ]]
	then
		OS='Mac'
	fi
	check_deps "$OS"
	bw_get_items "$OS"
}

main
