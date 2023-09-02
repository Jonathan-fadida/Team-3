#!/bin/bash
apt update
apt upgrade
apt install mysql-server
systemctl start mysql
systemctl enable mysql
