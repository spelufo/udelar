#!/bin/bash

# GRPS=$(echo *-grupos.json)
GRPS=$(echo humanidades-grupos.json)

for g in $GRPS; do
	echo $g >&2
	# s='.[] | "'
	# s="$s"'\t\"\(.id)\" [color=yellow,label=\"\(.id) [\(.min)-\(.max)]\"];\n'
	# s="$s"'\t\"\(.id)\" [color=yellow,label=\"\(.id) [\(.min)-\(.max)]\"];\n'
	# s="$s"'\t\"\(.id)\" -> \([.previas[].id] | @csv)'
	# s="$s"'"'
	s='.[]'
	s="$s"' | { id: .id, previas: .previas | map(.id) | map(select(. != null)), min: .min, max: .max }'
	s="$s"' | "\t\"\(.id)\" [color = yellow];\n\t\"\(.id)\" -> \(.previas | @csv) [color = blue];"'
	jq -r "$s" "$g" > "${g/.json/.dot}"
done

# CARRS=$(echo *[^p][^o][^s].json)
CARRS=$(echo humanidades-4-2.json)
echo '----' >&2

for carr in $CARRS; do
	dotfile="${carr/.json/.dot}"
	svgfile="${carr/.json/.svg}"
	echo $carr >&2

	echo "digraph Previas {" > "$dotfile"
	s='.[]'
	s="$s"' | { id: .id, nombre: .nombre, pcurso: .pcurso | map(.id) | map(select(. != null)), pexamen: .pexamen | map(.id) | map(select(. != null)) }'
	s="$s"' | "\t\"\(.id)\" [label=\"\(.nombre)\"];\n\t\"\(.id)\" -> \(.pcurso | @csv);\n\t\"\(.id)\" -> \(.pexamen | @csv) [color = red];"'
	jq -r "$s" "$carr" | sed '/\s->[^"]*;$/d' >> "$dotfile"
	cat "${carr/-*/}-grupos.dot" >> "$dotfile"
	echo '}' >> "$dotfile"

	echo "dot -Tsvg $dotfile -o $svgfile"

	dot -Tsvg "$dotfile" -o "$svgfile"

done
