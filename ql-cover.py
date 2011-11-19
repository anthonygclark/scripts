#!/usr/bin/env python2

# Anthony Clark
# Quod Libet Album Art Script.
# This fetches the album art for the playing song
# and places it in ~/.covers and /tmp/cover
# This is meant to be used with conky.
# This is also CPU intensive

import os
import shutil
import commands
import urllib

def copycover(currentalbum, src, dest, defaultfile):
    searchstring = currentalbum.replace(" ", "+")
    if not os.path.exists(src):
        url = "http://www.albumart.org/index.php?srchkey=" + searchstring + "&itempage=1&newsearch=1&searchindex=Music"
        cover = urllib.urlopen(url).read()
        image = ""
        for line in cover.split("\n"):
            if "http://www.albumart.org/images/zoom-icon.jpg" in line:
                image = line.partition('src="')[2].partition('"')[0]
                break
        if image:
            urllib.urlretrieve(image, src)
    if os.path.exists(src):
        shutil.copy(src, dest)
    elif os.path.exists(defaultfile):
        shutil.copy(defaultfile, dest)
    else:
        print "Image not found!"

# Path where the images are saved
imgpath = os.getenv("HOME") + "/.covers/"

# image displayed when no image found
noimg = imgpath + "nocover.png"

# Cover displayed by conky
cover = "/tmp/cover"

# Name of current album
album = commands.getoutput("quodlibet --print-playing \"<artist~album>\"")

# If tags are empty, use noimg.
if album == "":
    if os.path.exists(conkycover):
        os.remove(conkycover)
    if os.path.exists(noimg):
        shutil.copy(noimg, conkycover)
    else:
        print "Image not found!"
else:

    filename = imgpath + album + ".jpg"
    if os.path.exists("/tmp/nowplaying") and os.path.exists("/tmp/cover"):
        nowplaying = open("/tmp/cover").read()
        if nowplaying == album:
            pass
        else:
            copycover(album, filename, cover, noimg)
            open("/tmp/nowplaying", "w").write(album)
    else:
        copycover(album, filename, cover, noimg)
        open("/tmp/nowplaying", "w").write(album)
