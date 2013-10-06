#!/usr/bin/env python2

import traceback
from tvmover_common import TVDBShowMatcher
from tvmover_common import TransmissionShowMatcher
import sys
import os

if __name__ == '__main__':
	if len(sys.argv) > 1:
		t = TVDBShowMatcher(sys.argv[1])
	elif os.environ.get("TR_APP_VERSION"):
		try:
			t = TransmissionShowMatcher(True)
		except:
			t = TransmissionShowMatcher(False)
	else:
		print 'Usage: %s <file>' % sys.argv[0]
		sys.exit(0)
	
exc_type, exc_value, exc_traceback = sys.exc_info()
print "*** print_tb:"
traceback.print_tb(exc_traceback, limit=50, file=sys.stdout)
