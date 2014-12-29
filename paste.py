#!/usr/bin/env python2 
import sys
import datetime
import subprocess
import string
import random
import os
import io
import shutil

# This expects a layout like
# ~/web
#	|-- paste
#	|-- PASTE-*-* (generated from this script)
#	`-- static
#	    |-- bootstrap.min.css
#	    |-- bootstrap.min.js
#	    |-- bootstrap-theme.min.css
#	    `-- jquery.min.js
#
#
# To get the bootstrap files, visit
#  http://getbootstrap.com/customize
# 
# You need JQUERY >= 1.11
#
# You also need:
#	highlight >= 3.0
#   vim (with +html)


############## 
SERVER     = "http://localhost/paste"
PASTE_DIR  = "{}/web/paste".format(os.path.expanduser('~'))
BOOTSTRAP  = [
				'../../static/bootstrap.min.css', 
				'../../static/bootstrap-theme.min.css',
				'../../static/jquery.min.js',
				'../../static/bootstrap.min.js',
			]
STYLES     = [
				'nightshimmer'   , 'bclear'          , 'kellys'  ,
				'solarized-dark' , 'solarized-light' , 'night'   ,
				'bright'         , 'molokai'         , 'clarity' ,
				'darkspectrum'   , 'freya'           , 'fruit'   ,
				'kellys'         , 'matrix'          , 'print'
			]

HLCMD =\
"""highlight --style={style} -S {extension} -I --inline-css -i {file} -T {file} -K 9 -l -f --enclose-pre --replace-tabs=4 --anchors -y line"""

HEADER=\
"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{name}</title>

<link rel="stylesheet" href="{bs1}">
<link rel="stylesheet" href="{bs2}">

</head>
<body style="padding: 10px 50px 10px 50px; background-color: #6D6D6D;">
"""

DIV_WRAPPER=\
"""
<div class="panel panel-default">
    <div class="panel-heading">
        <span class="h3"><strong class="text-muted">{name}</strong></span>
    </div>
    <div class="panel-body">
        <a style="text-decoration: none !important;" href="{name}"><span class="label label-info">Download</span></a>
        <span class="label label-success">{extension}</span>
        <span class="label label-default">{size}</span>
        <span class="label label-default">{lines} lines</span>
        <span class="label label-default">{date}</span> 


		<div class="pull-right" style="padding-right:30px">
			<div class="btn-group">
				<button class="btn btn-primary btn-xs dropdown-toggle" type="button" data-toggle="dropdown">Color: %s  <span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
					{styles}
				</ul>
			</div>
		</div>

    </div>
</div>
<div class="well">
"""


FOOTER=\
"""
</div>

<script src="{bs3}"></script>
<script src="{bs4}"></script>
</body>
</html>
"""



def get_extension_type(ext):
	return {
		"c"   : "C"            ,
		"py"  : "Python"       ,
		"cu"  : "Cuda"         ,
		"cuh" : "Cuda Header"  ,
		"cpp" : "C++"          ,
		"cc"  : "C++"          ,
		"C"   : "C++"          ,
		"tcc" : "C++-Template" ,
		"rb"  : "Ruby"         ,
		"sh"  : "Bash/Shell"   ,
		"bat" : "Batch"        ,
		"java": "Java"         ,
		"h"   : "C-Header"     ,
		"hpp" : "C++-Header"   ,
		"m"   : "Objective-C"  ,
		"js"  : "JavaScript"   ,
		"s"   : "Assembly"     ,
		"lsp" : "LISP"         ,
		"lua" : "Lua"          ,
		"tcl" : "Tcl"          ,
		"log" : "Plain-Text"   ,
		"txt" : "Plain-Text"
	}.get(ext, ext.upper())


# returns filesize of a file
def get_size(path):
	size = float(os.stat(path).st_size)
	factors = (
			(1<<50L, 'PB'),
			(1<<40L, 'TB'),
			(1<<30L, 'GB'),
			(1<<20L, 'MB'),
			(1<<10L, 'KB'),
			(1, 'B')
	)

	for factor, suffix in factors:
		if size >= factor:
			break

	return '%.2f %s' % (size/factor, suffix)


# Builds random ID like mktemp
def id_generator():
	chars = string.ascii_uppercase + string.ascii_lowercase + string.digits
	return ''.join(random.choice(chars) for x in range(4))


# Make dir
def make_directory_structure(path, pname):
	dir_name = os.path.join(path, "PASTE-%s-%s" % (pname, id_generator()))
	os.mkdir(dir_name)
	return dir_name


def highlight_file(_file, _def_style, _dest):
	cmd = HLCMD.format(style=STYLES[0],
			extension=_ext,
			file=_file,
			dest=_dest).split(' ')
	
	html_buff = io.BytesIO()
	
	for style in STYLES:
		# could use --output-path
		if style == _def_style:
			dest = os.path.join(_dest, 'index.html'.format(style))
		else:
			dest = os.path.join(_dest, 'index-{}.html'.format(style))

		cmd = HLCMD.format(style=style,
				extension=_ext,
				file=_file,
				dest=dest)

		proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
				stderr=subprocess.PIPE, bufsize=-1)
		
		stdout, stderr = proc.communicate(html_buff.getvalue())
		if len(stderr):
			raise Exception(stderr)
		
		print '{0:20s} --> {1}'.format(style, dest)
		with open(dest, 'w+') as html:
			html.write(HEADER)
			html.write(DIV_WRAPPER % style)
			html.write(stdout)
			html.write(FOOTER)


if __name__ == '__main__':
	if len(sys.argv) < 2 or len(sys.argv) > 4:
		print "%s FILE [--style=STYLE] [--syntax=SYNTAX] [--vim]" % os.path.basename(sys.argv[0])
		sys.exit(1)

	_args_space_sep = [i.split('=') for i in sys.argv if '=' in i]
	args = [i[0] for i in _args_space_sep]
	vals = [i[1] for i in _args_space_sep]

	if '':
		sys.exit(1)
	
	# Get file properties and extension
	_file	  = os.path.abspath(sys.argv[1])
	_basename = os.path.basename(_file)
	_lines	  = sum(1 for line in open(_file))
	_date	  = datetime.datetime.now().strftime('%A, %b %d, %Y %I:%M%p')
	_size	  = get_size(_file)


	if len(sys.argv) == 3:
		_ext = sys.argv[2]
	else:
		_ext = os.path.splitext(_file)[1][1:] or 'txt'

	if len(sys.argv) == 4:
		_def_style = sys.argv[3]
		if _def_style not in STYLES:
			print 'Style %r not available' % _def_style
			print 'Available Styles:',', '.join(STYLES)
			sys.exit(2)
	else:
		_def_style = STYLES[0]
	
	styles_menu = []
	menu_str = '<li><a href=\"{0}.html\">{1}</a></li>\n'
	styles_menu.append(menu_str.format('index', _def_style))
	for style in filter(lambda x: x != _def_style, STYLES):
		styles_menu.append(menu_str.format(('index-'+style), style))
	
	# Preformat all of the HTML templates
	HEADER = HEADER.format(name=_file, bs1=BOOTSTRAP[0], bs2=BOOTSTRAP[1])
	
	DIV_WRAPPER = DIV_WRAPPER.format(
			name      = _basename,
			extension = get_extension_type(_ext),
			size      = _size,
			lines     = _lines,
			date      = _date,
			styles    = ''.join(styles_menu))

	FOOTER = FOOTER.format(bs3=BOOTSTRAP[2], bs4=BOOTSTRAP[3])

	# Create the dir
	_dest = make_directory_structure(PASTE_DIR, _basename)
	
	try:
		# Run highlight
		highlight_file(_file, _def_style, _dest)
		# Copy code to the dir
		shutil.copy(_file, _dest)
		# Print result
		print "{}/{}".format(SERVER, os.path.basename(_dest))
	except Exception as e:
		print '!! Reverting !!'
		print e
		shutil.rmtree(_dest)
		sys.exit(2)
