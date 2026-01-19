#!/bin/bash

# run for 3 days every 5 minutes.
for i  in {1..360}
do

    wall <<EOF
This O2 login node $(hostname -s) needs to be rebooted to apply a new kernel. Save your work and logoff after all your current jobs are finished.
EOF

    sleep 600
done
