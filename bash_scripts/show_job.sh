#!/usr/bin/env bash 

scontrol show job $1 | grep "End" 
