#!/usr/bin/env python2
import os, re, sys
import tvdb_api.tvdb_api
import difflib, shutil

SHOWS_DIR  = '/home/anthony/Stuff/TV'
SHOW_EXTS  = ['mp4', 'avi', 'mkv']

class TVShowMatcher(object):
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
	

	def __init__(self, input_file):
		self.real_file	= os.path.abspath(input_file)

		if not self.has_legal_ext(self.real_file):
			raise Exception('not a valid tv show file (according to name)')

		self.input_file = os.path.basename(input_file)
		tup 			= self.match_tv_show(self.input_file)
		
		if not tup:
			raise Exception('not a valid tv show file (according to name)')

		self.show, self.season, self.episode = tup


	def __repr__(self):
		return ' '.join(map(lambda x: str(x), (self.show, self.season, self.episode)))


	def does_match_date(self, string):
		''' Returns True is the string is a date as per the date_regexs '''
		for rx in self.date_regexps:
			if re.match(rx, string):
				return True
		return False


	def find_existing_show_dir(self):
		''' Uses difflib to find an existing dir for the show '''
		try:
			return difflib.get_close_matches(self.show, os.listdir(SHOWS_DIR))[0]
		except:
			return None


	def create_show_dir(self):
		try:
			_dir = os.path.join(SHOWS_DIR, self.show)
			os.mkdir(_dir)
			return _dir
		except OSError:
			return _dir
		except Exception:
			None

	def create_season_dir(self):
		try:
			_base = os.path.join(SHOWS_DIR, self.show)
			_dir  = os.path.join(_base, ('Season %s' % self.season))
			os.mkdir(_dir)
			return _dir
		except OSError as e:
			print e
			return _dir
		except Exception:
			None


	def has_legal_ext(self, name):
		return len(name) > 3 and name[-3:] in SHOW_EXTS


	def match_tv_show(self, string):
		''' Returns a 3-tuple containing show, season, ep num '''
		show 	= ''
		season	= ''
		episode	= ''

		try:
			for curr in self.episode_regexps:
				match = re.search(curr, string, re.IGNORECASE)
				if match:
					show = match.group('show')
					season = int(match.group('season'))
					episode = int(match.group('ep'))
	
			# do some filtering, remove common delimeters and filter out dates
			show = show.strip("._ ")
			show = re.split("[\._ ]", show)
			show = ' '.join(filter(lambda x: not self.does_match_date(x), show))
			return (show, season, episode)
		except Exception as e:
			return None


	# Moves file to SHOWS_DIR/<show>/<season> #/
	# Optionally creating season directory
	def move_file(self):
		target = ''
		
		# normalize dirs
		show_dir 	= os.path.join(SHOWS_DIR, self.show)
		season_dir 	= os.path.join(show_dir, ('Season %s' % self.season))
	
		if not self.find_existing_show_dir():
			show_dir = self.create_show_dir()
			if not show_dir:
				raise Exception('Could not move file - couldnt create show dir')
		
		season_dir = self.create_season_dir()
		if not season_dir:
			raise Exception('Could not move file - couldnt create season dir')

		## move show
		try:
			shutil.move(self.real_file, season_dir)
		except shutil.Error as e:
			pass

		print 'Done.'




class TVDBShowMatcher(TVShowMatcher):
	def __init__(self, inputfile):
		super(TVDBShowMatcher, self).__init__(inputfile)
		
		# api handle
		self.tvdb = tvdb_api.tvdb_api.Tvdb()
		
		try:
			self.ep_name = self.tvdb[self.show][self.season][self.episode]['episodename']
		except:
			raise Exception('TVDB api cannot find episode name')
		
		print "Using TVDB"
		self.move_file()


	def move_file(self):
		super(TVDBShowMatcher, self).move_file()
		ext = self.input_file[-4:]
		new = self.show + ' [%02dx%02d] ' % (self.season, self.episode) + self.ep_name + ext
		src = '/'.join(map(lambda x: str(x), [SHOWS_DIR, self.show, 'Season %d' % self.season, self.input_file]))
		dest= '/'.join(map(lambda x: str(x), [SHOWS_DIR, self.show, 'Season %d' % self.season, new]))

		os.rename(src,dest)



class TransmissionShowMatcher(object):
	def __init__(self, tvdb=False):
		# Transmission Vars
		self.tr_env_ver 	= os.environ.get("TR_APP_VERSION")
		self.tr_env_time 	= os.environ.get("TR_TIME_LOCALTIME")
		self.tr_env_dir 	= os.environ.get("TR_TORRENT_DIR")
		self.tr_env_hash 	= os.environ.get("TR_TORRENT_HASH")
		self.tr_env_id 		= os.environ.get("TR_TORRENT_ID")
		self.tr_env_name 	= os.environ.get("TR_TORRENT_NAME")

		path = os.path.join(self.tr_env_dir, self.tr_env_name)
		if tvdb:
			print "Using TVDB"
			t = TVDBShowMatcher(path)
		else:
			print "Not using TVDB"
			t = TVShowMatcher(path)

		t.move_file()
