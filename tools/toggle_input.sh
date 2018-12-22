#!/bin/bash
if setxkbmap -query | grep layout | grep -q pl; then
    setxkbmap se
else
    setxkbmap pl
fi
