#!/bin/bash

# carrera.json + groupo.json -> carrera.dot + carrera.svg
# 
# Usage: graph-carr carrfile grpfile [ranksfile]
#
# Example:
#	$ ./graph-carr ingenieria-22-8.json ingenieria-grupos-22-8.json ingenieria-ranksame-22-8.dot


# grupos .dot
g="$2"

s='.[]'
s="$s"' | [{from: .previas[] | {id: .id, pts: .puntaje, act: .actividad}, to: {id: .id, min: .min, max: .max}}]'
s="$s"' | .[] | "'
s="$s"'\t\"\(.to.id)\" [label=\"Grupo \(.to.id) [\(.to.min)-\(.to.max)]\", color=blue];\n'
s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\" ['
s="$s"'color=\"\(if .from.act == "Curso aprobado" then "grey" elif .from.act == "Examen aprobado" then "black" else "green" end)\"; '
s="$s"'headlabel=\"\(.from.pts)\"];"'
jq -r "$s" "$g" | sort -u | sed '/\s->[^"]*;$/d' > "${g/.json/.dot}"


# carr .dot
carr="$1"
dotfile="${carr/.json/.dot}"
graphfile="${carr/.json/.svg}"

echo "digraph Previas {" > "$dotfile"
echo $'\touputmode=edgesfirst;' >> "$dotfile"
echo $'\tranksep=3;' >> "$dotfile"

# carr += previas del examen
s='.[]'
s="$s"' | [ { from: .pexamen[] | (if .obs == false then ({id: .id, nombre: .nombre, act: .actividad}) else empty end), to: {id: .id, nombre: .nombre, act: "Examen"} } ]'
s="$s"' | .[] | "'
s="$s"'\t\"\(.to.id)\" [label=\"\(.to.nombre)\"];\n'
s="$s"'\t\"\(.from.id)\" [label=\"\(.from.nombre)\"];\n'
s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\" ['
# s="$s"'color=\"\(if .from.act == "Curso aprobado" then "grey" elif .from.act == "Examen aprobado" then "black" else "grey" end):red\"];"'
s="$s"'color=\"\(if .from.act == "Curso aprobado" then "grey" elif .from.act == "Examen aprobado" then "black" else "black" end)\"];"'
jq -r "$s" "$carr" | sort -u | sed '/\s->[^"]*;$/d' >> "$dotfile"

# carr += previas del curso
s='.[]'
s="$s"' | [ { from: .pcurso[] | (if .obs == false then ({id: .id, nombre: .nombre, act: .actividad}) else empty end), to: {id: .id, nombre: .nombre, act: "Curso"} } ]'
s="$s"' | .[] | "'
s="$s"'\t\"\(.to.id)\" [label=\"\(.to.nombre)\"];\n'
s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\" ['
# s="$s"'color=\"\(if .from.act == "Curso aprobado" then "grey" elif .from.act == "Examen aprobado" then "black" else "grey" end):orange\" ];"'
s="$s"'color=\"\(if .from.act == "Curso aprobado" then "grey" elif .from.act == "Examen aprobado" then "black" else "black" end)\", arrowhead=dot ];"'
jq -r "$s" "$carr" | sort -u | sed '/\s->[^"]*;$/d' >> "$dotfile"

# carr += grupos
cat "${g/.json/.dot}" >> "$dotfile"

# rank same asigs del mismo semestre
# [[ -f "$3" ]] && cat "$3" >> "$dotfile"

# </carr>
echo '}' >> "$dotfile"

echo '.dot file done' >&2
# dot2svg
gc -a "$dotfile" >&2
ccomps -X 1024 "$dotfile" > "${dotfile/.dot/.ccomps.dot}"
gc -a "${dotfile/.dot/.ccomps.dot}" >&2
# gc -a "$dotfile"

dot -Tsvg "${dotfile/.dot/.ccomps.dot}" -o "$graphfile"
