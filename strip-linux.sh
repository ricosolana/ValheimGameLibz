#!/bin/sh

toPublicize="Assembly-CSharp.dll assembly_valheim.dll assembly_utils.dll assembly_postprocessing.dll assembly_sunshafts.dll com.rlabrecque.steamworks.net.dll assembly_simplemeshcombine.dll assembly_lux.dll assembly_guiutils.dll assembly_googleanalytics.dll"
toIgnore="Mono.Security.dll mscorlib.dll"

exePath="$1"
echo "exePath: $exePath"

# Remove surrounding quotes if present
exePath=$(echo "$exePath" | sed 's/^"//;s/"$//')

managedPath="${exePath%.exe}_Data/Managed"
echo "managedPath: $managedPath"

scriptDir="$(cd "$(dirname "$0")" && pwd)"
outPath="$scriptDir/package/lib"

mkdir -p "$outPath"

# -----------------------------
# Runtime selection for NStrip
# -----------------------------
run_nstrip() {
    if command -v mono >/dev/null 2>&1; then
        mono "$scriptDir/tools/NStrip.exe" "$@"
    elif command -v wine >/dev/null 2>&1; then
        wine "$scriptDir/tools/NStrip.exe" "$@"
    else
        echo "Error: Neither mono nor wine is installed."
        exit 1
    fi
}

# Ask whether to keep Unity DLLs
printf "Keep Unity DLLs? (y/n): "
read keepUnity

# Strip all assemblies, but keep them private.
run_nstrip "$managedPath" -o "$outPath"

# Strip and publicize assemblies from toPublicize.
for a in $toPublicize; do
  echo "a: $a"
  run_nstrip "$managedPath/$a" -o "$outPath/$a" -cg -p --cg-exclude-events
done

# Removing unused packages
for a in $toIgnore; do
  echo "a: $a"
  rm -f "$outPath/$a"
done

# Conditionally remove Unity DLLs
case "$keepUnity" in
  y|Y)
    echo "Keeping Unity DLLs."
    ;;
  *)
    echo "Removing Unity DLLs."
    rm -f "$outPath"/Unity*.dll
    ;;
esac

# Always remove System DLLs
rm -f "$outPath"/System*.dll

read -p "Press Enter to continue..."