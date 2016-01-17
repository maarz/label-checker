import fileinput
import re
import urllib2
import json



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
      print "PR merged without review: %s" % line
    else:
      print "Reviewed: %s" % line
  else:
    print "No match: %s" % line

