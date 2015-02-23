#!/usr/bin/env node

// Usage: $ ./extract-previas.js <(cat [file])

var fs = require('fs')
var cheerio = require('cheerio')

fs.readFile(process.argv[2], function (err, contents) {
	var data = []

	var $ = cheerio.load(contents.toString())
	var table = $('center > table > tbody.unoa')
	var fields = [].slice.call(table.find('> tr:nth-child(1)').children().map(function (i, el) { return $(el).text().replace(/^\s+|\s+$/g,'') }))

	var id, nombre, actividad, lastid;
	var rows = table.find('> tr').each(function (i, el) {

		if (i === 0) return // skip the header

		var cid = $(el).find('> td:nth-child(1)').text() // id-materia
		var cnombre = $(el).find('> td:nth-child(2)').text() // nombre-materia
		var cactividad = $(el).find('> td:nth-child(3)').text() // actividad-material

		var sameid = /^\s*$/.test(cid)
		id = sameid ? id : cid
		nombre = sameid ? nombre : cnombre
		actividad = /^\s*$/.test(cactividad) ? actividad : cactividad
		tipoprevia = actividad === 'Examen' ? 'pexamen' : 'pcurso'

		if (id !== lastid) {
			data.push({
				id: id,
				nombre: nombre,
				pcurso: [],
				pexamen: []
			})
		}

		var pid = $(el).find('> td:nth-child(4)').text() // previa-id
		var pnombre = $(el).find('> td:nth-child(5)').text() // previa-nombre
		var pactividad = $(el).find('> td:nth-child(6)').text() // previa-actividad
		var pobs = $(el).find('> td:nth-child(7)').text() // previa-observacion

		if (/^\s*$/.test(pactividad)) {
			data[data.length - 1][tipoprevia].push({
				actividad: 'Créditos',
				cantidad: 1*pid,
				texto: pnombre.replace(/\s*\n\s*/, '. ')
			})
		} else {
			data[data.length - 1][tipoprevia].push({
				id: pid,
				nombre: pnombre,
				actividad: pactividad,
				obs: /\*/.test(pobs)
			})
		}

		lastid = id
	})

	data.forEach(function (d) {
		process.stdout.write(JSON.stringify(d)+'\n')
	})
})
