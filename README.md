# NinjaRPG: página y descargas

Página pública de descarga: <https://freshkz.github.io/ninja-rpg-builds/>. Se publica con GitHub Pages; el juego se
baja desde Releases (`NinjaRPG.zip`), sin cuenta de GitHub.

## Publicar una versión nueva

1. Generá el build de Windows en `C:\Proyectos\NinjaRPG` (menú `NinjaRPG/Build/Windows (release)`).
2. Doble clic en `publicar_juego.bat`. Comprime el build y lo sube como Release; la página baja siempre la última.

Requisitos en cada PC: este repo clonado al lado de `NinjaRPG` y `gh auth login` hecho.
Para probar sin subir nada: `publicar_juego.bat -Prueba` (deja el ZIP en el Escritorio).

Los dos jugadores tienen que usar la misma versión. Subí el ZIP siempre como Release, no con `git push`.

## Jugar juntos

Los dos instalan [Tailscale](https://tailscale.com/download) en la misma red. Uno elige **Crear partida** (el menú muestra
una IP `100.x`) y el otro elige **Unirse** y escribe esa IP.
