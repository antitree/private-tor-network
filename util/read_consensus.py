from stem.descriptor import parse_file
import sys

try:
  path = sys.argv[1]
  for desc in parse_file(path):
    print('found relay %s (%s)' % (desc.nickname, desc.fingerprint))
except IOError:
  print("File not found. make sure you supply it with a cached consensus file location: %s" % path)
