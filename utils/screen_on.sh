#!/bin/sh
tvservice --preferred
sleep 1
fbset -depth 8; fbset -depth 16; xrefresh -d :0
