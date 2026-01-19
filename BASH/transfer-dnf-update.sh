#!/usr/bin/env/bash 
set -x

pdsh -w transfer[02-10] 'dnf update --nobest --exclude=sensu --exclude=globus* --exclude=puppet* -y'
