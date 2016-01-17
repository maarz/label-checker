#!/bin/sh

git log --min-parents=2 --oneline master | python label-checker.py


