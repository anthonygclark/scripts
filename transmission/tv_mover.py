#!/usr/bin/env python2
#
# Anthony Clark
# Quick hack to move and organize downloaded
# TV shows to the SHOWS_DIR
#
# TODO, remove transmission deps


import os, re, sys
import difflib, shutil

#################################### Config
SHOWS_DIR  = '/home/anthony/Stuff/TV'
SHOW_EXTS  = ['mp4', 'avi', 'mkv']
###########################################


# Transmission Vars
tr_env_ver 	= os.environ.get("TR_APP_VERSION")
tr_env_time = os.environ.get("TR_TIME_LOCALTIME")
tr_env_dir 	= os.environ.get("TR_TORRENT_DIR")
tr_env_hash = os.environ.get("TR_TORRENT_HASH")
tr_env_id 	= os.environ.get("TR_TORRENT_ID")
tr_env_name = os.environ.get("TR_TORRENT_NAME")


# Regex's from Plex's Media Scanner
episode_regexps = [
	'(?P<show>.*?)[sS](?P<season>[0-9]+)[\._ ]*[eE](?P<ep>[0-9]+)([- ]?[Ee+](?P<secondEp>[0-9]+))?', # S03E04-E05
	'(?P<show>.*?)[sS](?P<season>[0-9]{2})[\._\- ]+(?P<ep>[0-9]+)',	 # S03-03
	'(?P<show>.*?)([^0-9]|^)(?P<season>[0-9]{1,2})[Xx](?P<ep>[0-9]+)(-[0-9]+[Xx](?P<secondEp>[0-9]+))?', # 3x03
  ]

date_regexps = [
	'(?P<year>[0-9]{4})[^0-9a-zA-Z]+(?P<month>[0-9]{2})[^0-9a-zA-Z]+(?P<day>[0-9]{2})([^0-9]|$)', # 2009-02-10
	'(?P<month>[0-9]{2})[^0-9a-zA-Z]+(?P<day>[0-9]{2})[^0-9a-zA-Z(]+(?P<year>[0-9]{4})([^0-9a-zA-Z]|$)', # 02-10-2009
	'\d{4}', # 2009
  ]



# True is string matches any of the regexs
def date_filter(string, rxs):
	for rx in rxs:
		if re.match(rx, string):
			return True
	return False


# Gets or creates show's root dir
def get_dir(show):
	try:
		return difflib.get_close_matches(show, os.listdir(SHOWS_DIR))[0]
	except:
		print 'creating show dir'
		os.mkdir(os.path.join(SHOWS_DIR, show))
		return show


# gets info from filename
def get_info(string):
	show 	= ''
	season 	= ''
	episode = ''
	
	try:
		for i in episode_regexps:
			match = re.search(i, string, re.IGNORECASE)
			if match:
				show = match.group('show')
				season = int(match.group('season'))
				episode = int(match.group('ep'))


		# do some filtering, remove common delimeters
		# and filter out dates
		show = show.strip("._ ")
		show = re.split("[\._ ]", show)
		show = ' '.join(filter(lambda x: not date_filter(x, date_regexps), show))
		show = get_dir(show)

		return (show, season, episode)

	except:
		print 'DEBUG: Failed to get show info'
		sys.exit(2)


# Checks extension (or last 3 chars) of the file against
# allowed types
def check_ext(name):
	return name[-3:] in SHOW_EXTS


# Moves file to SHOWS_DIR/<show>/<season> #/
# Optionally creating season directory
def move_file(path):
	target = ''
	
	# Go into downloaded dir or dir of downloaded file 
	os.chdir(path)

	# if we downloaded a dir, go into it
	if os.path.isdir(tr_env_name):
		print 'DEBUG: Media Type = directory'
		os.chdir(tr_env_name)

		if len(filter(lambda x: x.split('.')[1] in SHOW_EXTS, os.listdir('.'))) > 1:
			print 'DEBUG: Too many downloaded files to parse'
			sys.exit(3)
		
		# set target as the file
		target = filter(lambda x: x.split('.')[1] in SHOW_EXTS, os.listdir('.'))[0]
		# Set target to the `dir/filename` path
		target = os.path.join(tr_env_name, target)


	# We Downloaded the show directly
	else:
		print 'DEBUG: Media Type = file'
		if check_ext(tr_env_name):
			# Set target to downloaded thing
			target = tr_env_name
		else:
			print 'DEBUG: File does not have legal extension'
			sys.exit(1)


	# Get show info from filename
	info = get_info(os.path.basename(target))

	# normalize dirs
	show_dir 	= os.path.join(SHOWS_DIR, info[0])
	season_dir 	= os.path.join(show_dir, ('Season %s' % info[1]))

	print 'DEBUG:', "SHOW:",show_dir, "SEASON:",season_dir
	
	if not os.path.exists(season_dir):
		print 'creating seaons dir'
		os.mkdir(season_dir)
	
	
	# move show
	src = os.path.join(path, target)
	shutil.move(src, season_dir)
	print 'Success'




print 'Transmission Vars:'
print tr_env_ver 
print tr_env_time
print tr_env_dir 
print tr_env_hash
print tr_env_id  
print tr_env_name
print '------------------'

# do the work
move_file(tr_env_dir)
