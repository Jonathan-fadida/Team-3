#! /bin/bash

aws ec2 describe-images --owners self amazon --filters "Name=root-device-type,Values=ebs"
