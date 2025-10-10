#!/usr/bin/env bash

# Verifica que se haya pasado un argumento
if [ -z "$1" ]; then
    echo "Uso: $0 /ruta/al/wallpaper"
    exit 1
fi

WALLPAPER="$1"

# Matar cualquier instancia existente de mpvpaper (excepto este script)
pkill -f "mpvpaper -o" 2>/dev/null

# Lanzar el nuevo mpvpaper en segundo plano
nohup mpvpaper -o "no-audio loop hwdec=auto scale=bilinear interpolation=no video-sync=display-resample panscan=1.0 video-scale-x=1.0 video-scale-y=1.0 video-align-x=0.5 video-align-y=0.5 load-scripts=no" ALL "$WALLPAPER" >/dev/null 2>&1 &
