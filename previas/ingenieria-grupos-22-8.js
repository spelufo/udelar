#!/usr/bin/env node

// chop! chop! chop!

var fs = require('fs')
var carr = require('./ingenieria-22-8.json');
var grps = require('./ingenieria-grupos.json');
var grpfile = fs.createWriteStream('ingenieria-grupos-22-8.json')

var carrgrp = {}
var carrids = {}
var grrr = []

carr.forEach(function (c) {
	carrids[c.id] = true;
	c.pexamen.forEach(function (p) {
	  if (p.actividad === 'Grupo' && !p.obs) carrgrp[p.id] = true
	})
	c.pcurso.forEach(function (p) {
	  if (p.actividad === 'Grupo' && !p.obs) carrgrp[p.id] = true
	})
})

grps.forEach(function (g) {
	if (/^NO/.test(g.id)) return; // exclude grp that starts with NO
	if (!carrgrp[g.id]) return; // exclude grp that is not in carr

	// for the remaining groups exclude some asigs
	var ps = []
	g.previas.forEach(function (p) {
	  if (!carrids[p.id]) return; // exclude asigs not in 
	  if (p.actividad != 'Curso aprobado' && p.actividad != 'Examen aprobado') return; // exculde inscripciones y revalidas
	  ps.push(p)
	})
	if (ps.length) {
		g.previas = ps;
		grrr.push(g);
	}
})

grpfile.write(JSON.stringify(grrr,null,'\t')+'\n')