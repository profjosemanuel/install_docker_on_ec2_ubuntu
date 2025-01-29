#!/usr/bin/env bash

function check_privileges() {
if [ "$(id -u)" -ne 0 ]; then
    return 1
else
    return 0
fi
}


if ! check_privileges; then
   echo "no tenemos privilegios de usuario root"
fi
