# My Journal

Command line utility to encrypting/decrypting files for a private journal.

## Requeriments

* pandoc
* lynx
* vim
* openssl (command)

## Install

Just move myjournal.sh (and rename if you want to) to your PATH

## Usage

myjournal will automatically work under `$HOME/Documents/Journal` directory, and will ask every action for a password to
unlock the file `$HOME/Document/Journal/secret` which is going to be used as key for all encripted files.

Entries are stored on `$HOME/Documents/Journal/%Y-%m-%d` folders, with "entry.md.enc" as primary file.

### Edit text entry

`myjournal edit <entry>`

### View text entry

`myjournal view <entry>`

## TODO

I will be adding some other features such attaching and opening files, voice/video recording, archive managment and git integration,
however they are not prioritary and may take a while.
