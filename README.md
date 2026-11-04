# NinjaRPG: builds privados

Descargas de NinjaRPG para Fresh y su pareja. **Este repo tiene que seguir privado:** los builds llevan assets extraídos
con rip2unity, que no se publican ni se comparten con nadie más.

## Bajar el juego

1. Entrá a [la última versión](https://github.com/Freshkz/ninja-rpg-builds/releases/latest) con tu cuenta de GitHub (tenés que estar invitado o invitada al repo).
2. Bajá `NinjaRPG.zip`, descomprimilo y abrí `NinjaRPG.exe`. Si Windows avisa de una aplicación desconocida: **Más información → Ejecutar de todas formas**.

Los dos jugadores tienen que usar **la misma versión**.

## Jugar juntos

1. Los dos instalan [Tailscale](https://tailscale.com/download) en la misma red.
2. Uno elige **Crear partida**: el menú muestra una IP que empieza con `100.`.
3. El otro elige **Unirse** y escribe esa IP.

## Publicar una versión nueva (Fresh)

1. Generá el build de Windows en `C:\Proyectos\NinjaRPG` (menú `NinjaRPG/Build/Windows (release)`).
2. Doble clic en `publicar_juego.bat`. Solo frena si GitHub confirma que el repo es público; si hay un error al consultarlo, avisa y sigue.

Para probar sin subir nada: `publicar_juego.bat -Prueba` (deja el ZIP en el Escritorio).

### Subirlo a mano, sin el script

1. Armá el ZIP: en una terminal, dentro de esta carpeta, corré `.\publicar_juego.bat -Prueba`. Deja `NinjaRPG_prueba.zip` en el Escritorio, sin las carpetas de depuración.
2. Entrá a [crear una versión](https://github.com/Freshkz/ninja-rpg-builds/releases/new).
3. En **Choose a tag**, escribí una versión nueva (por ejemplo `v2026.11.04-1`) y elegí **Create new tag**.
4. Poné un título y arrastrá el ZIP a la zona de archivos. Esperá a que termine de subir.
5. Dejá marcado **Set as the latest release** y tocá **Publish release**.

Subí el ZIP siempre como Release, no con `git push` ni en la pestaña Code.

## Invitar a alguien

```powershell
gh api -X PUT repos/Freshkz/ninja-rpg-builds/collaborators/<usuario> -f permission=pull
```
