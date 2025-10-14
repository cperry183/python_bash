#!/bin/bash

# run for 3 days every 5 minutes.
for i  in {1..360}
do

    wall <<EOF
This O2 login node $(hostname -s) will be rebooted please save your work and logoff.
EOF

    sleep 600
done
