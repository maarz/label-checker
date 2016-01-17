import fileinput
import re
import urllib2
import json

not_reviewed = []
undetermined = []
reviewed = []

pattern = re.compile(r".*#([0-9]+)")
for line in fileinput.input():
  match = pattern.match(line)
  if match is not None:
    pull_number = match.group(1)
    
    print "Getting pull request: %s" % pull_number
    pull_request = urllib2.urlopen("https://api.github.com/repos/maarz/label-checker/issues/" + pull_number).read()
    
    review_count = 0
    for label in json.loads(pull_request)["labels"]:
       if label["name"] in ["Opfikon reviewed", "Budapest reviewed", "Speeder reviewed"]:
         review_count = review_count + 1

    if review_count < 2:
      not_reviewed.append(line)
    else:
      reviewed.append(line)
  else:
    undetermined.append(line)

if len(not_reviewed) != 0:
  print "Not reviewed pulls:"
  for line in not_reviewed:
    print " %s" % line
else:
  print "No unreviewed pull found"

if len(undetermined) != 0:
  print "Undetermined merges:"
  for line in undetermined:
    print " %s" + line
else:
  print "No undetermined pull found"

