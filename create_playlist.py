#!/usr/bin/env python2
# Quick hack to concat some playlists
# The playlists I was messing with had no
# artists/album metadata...
#
# This is just a hack. Only use this if you 
# dont expect stable results, haha.

import os, sys

usage = """Usage:
%s -i <dir of playlists> -o <output playlist file>

Takes all playlists in input dir and outputs a giant playlist. """ % sys.argv[0]

inputDir = None
outputFile = None

if '-i' in sys.argv and '-o' in sys.argv:
    inputDir = sys.argv[sys.argv.index('-i')+1]
    outputFile = sys.argv[sys.argv.index('-o')+1]
elif '-h' in sys.argv or '--help' in sys.argv:
    print usage
    sys.exit(1)
else:
    print usage
    sys.exit(1)

print 'Looking in %s to find playlists.' % inputDir
playlists = os.listdir(inputDir)
playlists = [p for p in playlists if p.endswith('.pls')]
numOfPlaylists = len(playlists)

print 'Found %s playlists' % numOfPlaylists
if not numOfPlaylists:
    print 'Exiting'
    sys.exit(2)

print '\n'.join(playlists)

result = ["[playlist]\nNumberOfEntries=%s\n" % numOfPlaylists]

for i, playlist in enumerate(playlists):
    with open(os.path.join(inputDir, playlist), 'r') as playlist:
        # ignore header lines
        g = playlist.readline()
        g = playlist.readline()

        url = playlist.readline().strip().split('=')[1]
        title = playlist.readline().strip().split('=')[1]
        result.append("File%d=%s\nTitle%d=%s\nLength%d=-1\n" % (i+1, url, i+1, title,i+1))

result.append("Version=2\n")

# Write output file
print 'Writing mega playlist to %s' % outputFile
output = open(outputFile, 'w')
for r in result:
    output.write(r)
output.close()

print "Playlist written to %s" % (os.path.abspath(outputFile))
