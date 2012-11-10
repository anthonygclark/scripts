#!/usr/bin/env python2
import sys, datetime, subprocess, string, random, os, shutil

# Anthony Clark
# Simple paste service.
# Requires: bootstrap.min.css

############## 
PASTE_DIR = "/home/anthony/web/paste"
SERVER    = "http://aclarkdev.dyndns.org/paste"
BOOTSTRAP_LOCATION = "../../static/bootstrap.min.css"
##############

HLCMD =\
"""highlight --style=moria -S {0} -I --inline-css -i {1} -T {2} > {3}"""

DIV_WRAPPER=\
"""
<link href='%s' rel='stylesheet'>
</head>
<div class="container">
  <br>
  <div class="navbar">
    <div class="navbar-inner">
    <a class="brand" href="#">{0}</a>
    <a class="btn btn-info" href="{0}">Download</a>
    <span class="label label-success">{1}</span>
    <span class="label label-inverse">size: {2}</span>
    <span class="label label-inverse">lines: {3}</span>
    <span class="label label-inverse">{4}</span>
    </div>
  </div>
<body>
""" % BOOTSTRAP_LOCATION


FOOTER=\
"""
</div>
</body>
</html>
"""
#############

# Returns nice extension identification
def get_extension_type(ext):
    return {
        "py"  : "Python",
        "c"   : "C",
        "cu"  : "Cuda",
        "cuh" : "Cuda Header",
        "cpp" : "C++",
        "rb"  : "Ruby",
        "sh"  : "Shell",
        "bat" : "Batch",
        "java": "Java",
        "h"   : "C-Header",
        "m"   : "Objective-C",
        "js"  : "JavaScript",
        "s"   : "Assembly"
    }.get(ext, "Plain-Text")


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



def mkdir(path):
    dir_name = os.path.join(path, "PASTE.%s" % (id_generator()))
    os.mkdir(dir_name)
    return dir_name



# Inserts modifications
def insert_div(path, ext, name, size, line_count, date):
    lines = []
    ext_name = get_extension_type(ext)
    div = DIV_WRAPPER.format(name, ext_name, size, line_count, date)

    # Remove stuff and add our div
    # and footer
    with open(path, 'r') as inf:
        lines = inf.readlines()
        del lines[5]
        lines[5] = div
        lines = lines[:-3]
        lines.append(FOOTER)
        
    # write to new file
    with open(path, 'w') as inf:
        inf.write(''.join(lines))       


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print "%s <file.extenstion>" % os.path.basename(sys.argv[0])
        sys.exit(1)

    # Get file properties and extension
    _file     = os.path.abspath(sys.argv[1])
    _basename = os.path.basename(_file)
    _lines    = sum(1 for line in open(_file))
    _date     = datetime.datetime.now().strftime('%A, %b %d, %Y %I:%M%p')
    _size     = get_size(_file)

    # Parse out extension
    try:
        _ext = os.path.splitext(_file)[1][1:]
    except:
        _ext = 'txt'

    # Create the dir
    _dest = mkdir(PASTE_DIR)
    _out  = os.path.join(_dest, "index.html")
    
    # Copy code to the dir
    shutil.copy(_file, _dest)

    # Run highlight
    try:
        subprocess.call(HLCMD.format(_ext, _file, _basename, _out), shell=True)
    except:
        print 'Error. Reverting'
        shutil.rmtree(_dest)
        sys.exit(2)

    # fix HTML
    insert_div(_out, _ext, _basename, _size, _lines, _date)

    # Print result
    print "{}/{}".format(SERVER, os.path.basename(_dest))
