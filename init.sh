#!/bin/bash
USER_PASSWORD=`pwgen -c -n -1 12`
echo "devop password: $USER_PASSWORD"
echo "devop password user $USER_PASSWORD" >> /passwords

echo "devop:${USER_PASSWORD}" | chpasswd