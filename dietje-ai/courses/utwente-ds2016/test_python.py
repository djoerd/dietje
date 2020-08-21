import re
import sys
with open("/usr/share/dict/words") as f:
    for line in f.readlines():
        if (re.match(sys.argv[1], line)):
            print line,
