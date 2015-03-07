#!/usr/bin/env node

// Usage: $ ./extract-grupos.js <(iconv -f ISO-8859-1 -t UTF-8 file) [outfile]

var fs = require('fs')
var cheerio = require('cheerio')

var extract = function (file, cbk) {

	fs.readFile(file, {encoding: 'utf8'}, function (err, contents) {
		var data = []

		var $ = cheerio.load(contents)
		var tables = $('center > table > tbody.unoa')
		var ps = $('p.och')
		var errs = 0
		for (var i = 0; i < tables.length; i++) {
			var m = /.*\s([\w\*]+)\-(?:.*\n)+.*(\d+).*\n.*(\d+).*$/i.exec($(ps[i*2+1]).text())
			if (m === null) {
				process.stderr.write(new Buffer('Error parsing group info:\n' + $(ps[i*2+1]).text()))
			} else {
				var grupo = {
					id: m[1] ? 'G_' + m[1] : '',
					min: m[2]*1 || 0,
					max: m[3]*1 || 0,
					previas: []
				}
				$(tables[i]).find('> tr').each(function (i, tr) {
					if (i === 0) return;
					var row = $(tr)

					var pactividad = row.find('> td:nth-child(3)').text()
					var pid = row.find('> td:nth-child(1)').text()
					grupo.previas.push({
						id: pactividad === 'Grupo' ? 'G_' + pid : pid,
						nombre: row.find('> td:nth-child(2)').text(),
						actividad: pactividad,
						puntaje: row.find('> td:nth-child(4)').text()*1
					})
				})
			}
			data.push(grupo)
		}

		cbk(data)
	})
}

if (module.parent) {
	module.exports = extract
} else {
	extract(process.argv[2], function (data) {
		if (process.argv[3]) {
			fs.createWriteStream(process.argv[3], {encoding: 'utf8'}).write(JSON.stringify(data, null, '\t'), 'utf8')
		} else {
			data.forEach(function (d) {
				process.stdout.write(JSON.stringify(d)+'\n')
			})
		}
	})
}
