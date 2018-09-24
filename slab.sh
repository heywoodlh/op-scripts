#!/usr/bin/env bash

OP_TEAM='team_cues'


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
		PACKAGES=(op xclip rofi jq zenity)
	elif [[ "$OS" == 'Mac' ]]
	then
		PACKAGES=(op choose jq)
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


op_get_items () {
	OS="$1"
	if [ ! -f ~/.op_session ]
	then
		if [[ "$OS" == 'Mac' ]]
		then
			VAULT_PW="$(osascript -e "display notification \"Please sign into OP\"")"
			exit
		elif [[ "$OS" == 'Linux' ]]
		then
			#VAULT_PW="$(zenity --password)"
			exit
		fi
	else
		VAR="OP_SESSION_$OP_TEAM"
		eval "$VAR"="$(cat ~/.op_session)"
	fi

	if [[ "$OS" == 'Linux' ]]
	then
		SELECTION="$(op list items --search 'sudolikeaboss://' --session "$OP_SESSION" | jq -r '.[].name' | rofi -dmenu -p 'slab: ')"
		op get item "$SELECTION" | jq  -r '.details.fields[] | select(.designation == "password") | .value' | xclip -selection clipboard
	elif [[ "$OS" == 'Mac' ]]
	then
		SELECTION="$(op list items | jq -r '.[] | select(.overview.url == "sudolikeaboss://") | .overview.title' | choose)"
		op get item "$SELECTION" | jq  -r '.details.fields[] | select(.designation == "password") | .value' | pbcopy
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
	op_get_items "$OS"
}

main
