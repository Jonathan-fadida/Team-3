#!/bin/bash
apt update
apt upgrade
apt get install mysql-server
systemctl start mysql
systemctl enable mysql
