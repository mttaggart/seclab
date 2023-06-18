#!/bin/bash
mkisofs -J -l -R -V "Autounattend" -iso-level 4 -o Autounattend.iso $1
