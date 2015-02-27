#!/bin/bash

# GRPS=$(echo *-grupos.json)
GRPS=$(echo ingenieria-grupos.json)

for g in $GRPS; do
	s='.[]'
	s="$s"' | [{from: .previas[] | {id: .id, pts: .puntaje, act: .actividad}, to: {id: .id, min: .min, max: .max}}]'
	s="$s"' | .[] | "'
	s="$s"'\t\"\(.to.id)\" [label=\"\(.to.id) [\(.to.min)-\(.to.max)]\"];\n'
	s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\" [constraint=false,label=\"\(.from.pts)\",color=\(if .from.act == "Curso aprobado" then "orange" else "yellow" end)];"'
	jq -r "$s" "$g" | uniq | sed '/\s->[^"]*;$/d' > "${g/.json/.dot}"
done

# CARRS=$(echo *[^p][^o][^s].json)
CARRS=$(echo ingenieria-22-8.json)
echo '[grupos done]' >&2

for carr in $CARRS; do
	dotfile="${carr/.json/.dot}"
	pngfile="${carr/.json/.svg}"
	echo "[$carr done]" >&2

	echo "digraph Previas {" > "$dotfile"
	# echo $'\touputmode=edgesfirst;' >> "$dotfile"

	# previas del examen
	s='.[]'
	s="$s"' | [ { from: .pexamen[] | (if .obs == false then ({id: .id, nombre: .nombre, act: .actividad}) else empty end), to: {id: .id, nombre: .nombre, act: "Examen"} } ]'
	s="$s"' | .[] | "'
	s="$s"'\t\"\(.to.id)\" [label=\"\(.to.nombre)\"];\n'
	s="$s"'\t\"\(.from.id)\" [label=\"\(.from.nombre)\"];\n'
	s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\";"'
	jq -r "$s" "$carr" | uniq | sed '/\s->[^"]*;$/d' >> "$dotfile"

	# previas del curso
	s='.[]'
	s="$s"' | [ { from: .pcurso[] | (if .obs == false then ({id: .id, nombre: .nombre, act: .actividad}) else empty end), to: {id: .id, nombre: .nombre, act: "Curso"} } ]'
	s="$s"' | .[] | "'
	s="$s"'\t\"\(.from.id)\" [label=\"\(.from.nombre)\"];\n'
	s="$s"'\t\"\(.to.id)\" [label=\"\(.to.nombre)\"];\n'
	s="$s"'\t\"\(.from.id)\" -> \"\(.to.id)\" [color=blue];"'
	jq -r "$s" "$carr" | uniq | sed '/\s->[^"]*;$/d' >> "$dotfile"

	cat "${carr/-*/}-grupos.dot" >> "$dotfile"
	echo '}' >> "$dotfile"

	dot -Tsvg <(tred <(uniq "$dotfile")) -o "$pngfile" 2>dot.log
	echo "[$pngfile done]" >&2

done
