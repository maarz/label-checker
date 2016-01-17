import fileinput
import re
import urllib2

pattern = re.compile(r".*#([0-9]+)")
for line in fileinput.input():
  match = pattern.match(line)
  if match is not None:
    pull_number = match.group(1)
    pull_request = urllib2.urlopen("https://api.github.com/repos/maarz/label-checker/pulls/" + pull_number).read()
    print pull_request
  else:
    print "No match: %s" % line

