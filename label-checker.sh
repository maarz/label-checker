#!/bin/sh

git log --min-parents=2 --oneline origin/master | python label-checker.py


