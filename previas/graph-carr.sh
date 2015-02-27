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
s="$s"'\t\"\(.to.id)\" [label=\"Grupo \(.to.id) [\(.to.min)-\(.to.max)]\", color=yellow];\n'
s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\" ['
s="$s"'color=\(if .from.act == "Curso aprobado" then "orange" elif .from.act == "Examen aprobado" then "grey" else "green" end),'
s="$s"'headlabel=\"\(.from.pts)\"];"'
jq -r "$s" "$g" | sed '/\s->[^"]*;$/d' > "${g/.json/.dot}"


# carr .dot
carr="$1"
dotfile="${carr/.json/.dot}"
graphfile="${carr/.json/.svg}"

echo "digraph Previas {" > "$dotfile"
echo $'\touputmode=edgesfirst;' >> "$dotfile"
echo $'\tranksep=1;' >> "$dotfile"

# carr += previas del examen
s='.[]'
s="$s"' | [ { from: .pexamen[] | (if .obs == false then ({id: .id, nombre: .nombre, act: .actividad}) else empty end), to: {id: .id, nombre: .nombre, act: "Examen"} } ]'
s="$s"' | .[] | "'
s="$s"'\t\"\(.to.id)\" [label=\"\(.to.nombre)\"];\n'
s="$s"'\t\"\(.from.id)\" [label=\"\(.from.nombre)\"];\n'
s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\";"'
jq -r "$s" "$carr" | sed '/\s->[^"]*;$/d' >> "$dotfile"

# carr += previas del curso
s='.[]'
s="$s"' | [ { from: .pcurso[] | (if .obs == false then ({id: .id, nombre: .nombre, act: .actividad}) else empty end), to: {id: .id, nombre: .nombre, act: "Curso"} } ]'
s="$s"' | .[] | "'
s="$s"'\t\"\(.from.id)\" [label=\"\(.from.nombre)\"];\n'
s="$s"'\t\"\(.to.id)\" [label=\"\(.to.nombre)\"];\n'
s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\" [color=blue];"'
jq -r "$s" "$carr" | sed '/\s->[^"]*;$/d' >> "$dotfile"

# carr += grupos
cat "${g/.json/.dot}" >> "$dotfile"

# rank same asigs del mismo semestre
[[ -f "$3" ]] && cat "$3" >> "$dotfile"

# </carr>
echo '}' >> "$dotfile"

# dot2svg
uniq "$dotfile" | dot -Tsvg -o "$graphfile"
