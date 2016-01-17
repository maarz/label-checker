#!/bin/sh

if [ -z $1 ]; then
  after="1 week ago"
else
  after=$1
fi

git log --min-parents=2 --oneline --after="$after" origin/master | python label-checker.py


