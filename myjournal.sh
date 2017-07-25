#!/bin/bash
ACTION="$1"
ENTRY="$2"
BASE="$HOME/Documents/Journal"
KEYFILE="$BASE/secret"

if [[ "$ENTRY" -eq "today" ]] || [[ -z "$ENTRY" ]]; then
    ENTRY=$(date +"%Y-%m-%d")
fi

DIRECTORY="$BASE/$ENTRY"
TMPDIR="$(mktemp -d)/$ENTRY"
[ -d "$DIRECTORY" ] || mkdir -p "$DIRECTORY"
[ -d "$TMPDIR" ] || mkdir -p "$TMPDIR"

echo -n "Password: "
read -s KEYPASSWORD
echo

if [ -e "$KEYFILE" ]; then
    PASSWORD=$(openssl aes-256-cbc -d -a -in "$KEYFILE" -k "$KEYPASSWORD" > /dev/null 2>&1)
    if [ "$?" -ne 0 ]; then
        echo "Bad password"
        exit 1
    fi
else
    PASSWORD=$(openssl rand -hex 12)
    echo "$PASSWORD" | openssl aes-256-cbc -a -salt -out "$KEYFILE" -k "$KEYPASSWORD"
fi

# myjournal edit
function editEntry {
    RAWFILE="$TMPDIR/entry.md"
    ENCFILE="$DIRECTORY/entry.md.enc"

    if [ -e "$ENCFILE" ]; then
        openssl aes-256-cbc -d -a -in "$ENCFILE" -out "$RAWFILE" -k "$PASSWORD" > /dev/null 2>&1
    fi

    vim "$RAWFILE"
    echo "" >> "$RAWFILE"
    echo ">>> Edited by $USER at _$(date +'%D %T')_" >> "$RAWFILE"
    openssl aes-256-cbc -a -salt -in "$RAWFILE" -out "$ENCFILE" -k "$PASSWORD" > /dev/null 2>&1

    rm -f "$RAWFILE"
}

# myjournal view
function viewEntry {
    RAWFILE="$TMPDIR/entry.md"
    ENCFILE="$DIRECTORY/entry.md.enc"

    if [ -e "$ENCFILE" ]; then
        openssl aes-256-cbc -d -a -in "$ENCFILE" -out "$RAWFILE" -k "$PASSWORD" > /dev/null 2>&1
        chmod ugo-w "$RAWFILE"
        pandoc "$RAWFILE" | lynx -stdin
    else
        echo "File does not exist"
        exit 1
    fi

    rm -f "$RAWFILE"
}

case "$ACTION" in
    "edit")
        editEntry
        ;;
    "view")
        viewEntry
        ;;
    *)
        echo "Unknown action $ACTION"
        exit 1
        ;;
esac

rm -rf "$TMPDIR"
