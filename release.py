#!/usr/bin/env python
#
# This is an INCOMPLETE, work-in-progress rewrite of the "release" shell script in Python.
# The motivation for this rewrite is that it is actually much easier to write portable
# Python code than it is to write portable shell scripts. Moreover, in Python a lot of
# other things become easier, e.g. parsing the JSON output returned by GitHub requests.
#
# On the downside, invoking external tools is a bit more annoying...#
#
# This script should only use Python libraries that are shipped with Python.
# It should also stay compatible with all Python versions >= 2.7, including Python 3.
#

import sys

def notice(msg):
    print("\033[32m" + msg + "\033[0m")

def warning(msg):
    print("\033[33m" + msg + "\033[0m")

def error(msg):
    print("\033[31m" + msg + "\033[0m")
    exit(1)

if sys.version_info < (2,7):
    error("Python 2.7 or newer is required")

# load modules after version check
import json
import argparse




parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
description="""A tool for making releases of GAP packages on GitHub.

Run this from within a git clone of your package repository, checked out
at the revision you want to release. This tool extracts relevant data
from the PackageInfo.g file, and performs the releases process.""",
epilog="""Notes:
* The package name and version, the list of archive formats, and the GitHub repository
  are extracted from PackageInfo.g.
* To learn how to create a GitHub access token, please consult
  https://help.github.com/articles/creating-an-access-token-for-command-line-use/
* Without the --push option, all steps are performed, except for the final push
  of the gh-pages changes. These changes are what make the release visible
  to the GAP package distribution system.
* Please consult the README for more information.
""")

parser.add_argument('-p', '--push', action='store_true',
                    help='also peform the final push, completing the release')
parser.add_argument('-f', '--force', action='store_true',
                    help='if a release with the same name already exists: overwrite it')

group = parser.add_argument_group('Paths')

group.add_argument('--srcdir', type=str,
                    help='directory containing PackageInfo.g (default: current directory)')
group.add_argument('--tmpdir', type=str,
                    help='path to the source directory (default: tmp subdirectory of src)')
group.add_argument('--webdir', type=str,
                    help='path to the web directory (default: gh-pages subdirectory of src)')

group = parser.add_argument_group('Repository access')

group.add_argument('--token', type=str,
                    help='GitHub access token')
# group.add_argument('-t', '--tag', type=str,
#                     help='git tag for the release (default: vVERSION, e.g. v1.2.3)')
# group.add_argument('-r', '--repository', type=str,
#                     help='set GitHub repository (as `USERNAME/PKGNAME`)')
group.add_argument('--remote', type=str, default="origin",
                    help='git remote to which tags are pushed (default: origin)')



#parser.add_argument('--version', action='version', version='%(prog)s 2.0')


args = parser.parse_args()
print args





#obj=json.load(sys.stdin);

