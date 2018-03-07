#!/bin/sh
# A short script to append user:pass:10 to auth file
# info@sinaptika.net

echo "Please enter the username you would like to use for Deluge daemon:"
read deluged_user
deluged_pass="$(pwgen -1 8)"
echo ${deluged_user}:${deluged_pass}:10 >> ${D_DIR}/config/auth
echo -------------------------------
echo Deluged username: $deluged_user
echo Deluged password: $deluged_pass
echo -------------------------------
