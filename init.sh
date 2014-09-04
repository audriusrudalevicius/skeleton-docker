#!/bin/bash
USER_PASSWORD=`pwgen -c -n -1 12`
echo "devop password: $USER_PASSWORD"
echo "devop password (user and mysql): $USER_PASSWORD" >> /passwords
create-sistearth-user
echo "devop:${USER_PASSWORD}" | chpasswd

sleep 2s
