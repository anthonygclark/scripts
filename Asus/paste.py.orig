#!/usr/bin/env python2
import sys, datetime, subprocess, string, random, os, shutil

# Anthony Clark
# Simple paste service.
# Requires: bootstrap.min.css
#
# TODO fallback for missing bootstrap css
#

############## 
PASTE_DIR = "/home/anthony/web/paste"
SERVER	  = "http://aclarkdev.dyndns.org/paste"
BOOTSTRAP_LOCATION = "../../static/bootstrap.min.css"
##############

HLCMD =\
"""highlight --style=moria -S {0} -I --inline-css -i {1} -T {2} > {3}"""

HLCMD_N =\
"""highlight --style=moria -l -S {0} -I --inline-css -i {1} -T {2} > {3}"""

DIV_WRAPPER=\
"""
<link href='%s' rel='stylesheet'>
</head>
<div class="panel">
  <div class="panel-heading">
    <h3 class="panel-title">{0}</h3>
        <br>
		<a style="text-decoration: none !important;" href="{0}"><span class="label label-info">Download</span></a>
		<a style="text-decoration: none !important;" href="{link}"><span class="label label-info">{text}</span></a>
		<span class="label label-success">{1}</span>
		<span class="label label">{2}</span>
		<span class="label label">{3} lines</span>
		<span class="label label">{4}</span>
  </div>
<body>

""" % (BOOTSTRAP_LOCATION)


FOOTER=\
"""
<div class="panel-footer">
	<a style="text-decoration: none !important;" href="#top"><span class="label label">&uarr;</span>
</div>
</div>
</body>
</html>
"""
#############

# Returns nice extension identification
# 
# Passed "txt" if we cannot get extension
# from file at read time.
#
# We fallback on using the file extension as
# its type if we dont have nice mapping for it
def get_extension_type(ext):
	return {
		"c"   : "C",
		"py"  : "Python",
		"cu"  : "Cuda",
		"cuh" : "Cuda Header",
		"cpp" : "C++",
		"rb"  : "Ruby",
		"sh"  : "Bash",
		"bat" : "Batch",
		"java": "Java",
		"h"   : "C-Header",
		"m"   : "Objective-C",
		"js"  : "JavaScript",
		"s"   : "Assembly",
		"lsp" : "LISP",
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
def mkdir(path, pname=""):
	dir_name = os.path.join(path, "PASTE-%s-%s" % (id_generator(), pname))
	try:
		os.mkdir(dir_name)
	except Exception as e:
		print e
		sys.exit(1)
	return dir_name


# Inserts modifications
# Because we have 2 index files, (with/without lines),
# we have a button in our div that we want different
# for each index.
def insert_div(path, data, link, text):
	lines = []

	# Fill in data, 
	div = DIV_WRAPPER.format(*data, link=link, text=text)
 
	# Remove stuff and add our div
	# and footer
	with open(path, 'r') as inf:
		lines = inf.readlines()
		lines[5] = div
		lines[6] = ""
		lines = lines[:-3]
		lines.append(FOOTER)

	# write to new file
	with open(path, 'w') as inf:
		inf.write(''.join(lines))		



if __name__ == '__main__':
	if len(sys.argv) < 2:
		print "%s FILE [SYNTAX]" % os.path.basename(sys.argv[0])
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
		# Parse out extension from file
		_ext = os.path.splitext(_file)[1][1:]
	
	# Assure there is SOMETHING in the ext
	if not _ext: _ext = 'txt'

	# Create the dir
	_dest	= mkdir(PASTE_DIR, os.path.basename(_file))
	if not _dest: sys.exit(1)

	# Set output file names
	_out	= os.path.join(_dest, "index.html")
	_out_n	= os.path.join(_dest, "index_num.html")
	
	# Copy code to the dir
	shutil.copy(_file, _dest)

	# Run highlight
	try:
		subprocess.check_call(HLCMD.format(_ext, _file, _basename, _out), shell=True)
		subprocess.check_call(HLCMD_N.format(_ext, _file, _basename, _out_n), shell=True)
	except:
		print 'Reverting.'
		shutil.rmtree(_dest)
		sys.exit(2)

	# fix HTML
	insert_div(_out, [_basename, get_extension_type(_ext), _size, _lines, _date], "index_num.html", "Show Line Numbers")
	insert_div(_out_n, [_basename, get_extension_type(_ext), _size, _lines, _date], "index.html", "Hide Line Numbers")

	# Print result
	print "{}/{}".format(SERVER, os.path.basename(_dest))
