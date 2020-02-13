This file describes changes in the **ReleaseTools** for GAP packages.

Note: only changes in the script visible to the user are mentioned; internal
changes and also improvements to the `README.md` are not covered.


- 2020-02-12:
  - Rename the `release` script to `release-gap-package` to make it
    convenient for use in your PATH
  - Give a more helpful error message if a release is aborted due to
    uncommitted changes
  - Fix the (undocumented!) `--only-tarball` option

- 2020-02-10:
  - Switch to a new GitHub authentication scheme, to ensure things will
    keep working beyond July 2020 (when GitHub turns of the old scheme)

- 2019-11-11:
  - Remove options `-t` / `--token` and `-r` / `--repository`:  they were
    broken for a long time. Since nobody complained, I am assuming nobody
    used them. Since I can't think of a good usecase anymore (now that
    extract all this data from the ArchiveURL), removing them seems the
    best way to go forward. If at some point somebody wants to have them
    back, I'll be happy to consider that as well, based on discussions
    with the people requesting it.
  - Change defaults and enable the "last push" (to the website) by default
  - Added option `-P` as a shorthand for `--no-push`

- 2019-03-26:
  - Keep doc/*.toc files: the help system uses them when displaying PDF and
    DVI files

- 2018-09-18
  - Fix a compatibility issue with the `dash` shell (used by Debian)

- 2018-05-07
  - Fix support for "annotated tags"

- 2018-04-19
  - Fix a compatibility issue with BSD sed (default on Mac OS X)

- 2018-02-13
  - Add support for `.release` scripts in package: if a package contains
    such a script in its root directory, then we read it while preparing
    the source archive content. This allows many customizations, such as
    adding non-tracked files to the distribution, or removing additional
    files from distribution, custom build steps and more.

- 2018-02-13
   - Check for broken hyperlinks in even more HTML files (e.g. now also in
    `htm/*.htm`)

- 2017-09-14:
   - Validate `README_URL` field: e.g. we now catch if a `README` files was
     renamed to `README.md` but the `README_URL` field in `PackageInfo.g`
     was not updated accordingly
   - Add alternate syntax for `--{src,web,tmp}dir` options: now instead of
     writing e.g. `-srcdir DIR` one can also write `-srcdir=DIR`
   - Detect if HTML files in `doc/` contain hyperlinks with an absolute
     path (usually that hints at an issue with the generation of the manual)

- 2017-09-08:
   - Make the `--remote` option unnecessary and remove it
   - Fix compatibility with python3 (we use a little bit of python code
     inside the `release` script)
   - Fix a dangerous bug where an empty value of the `TMP_DIR` variable
     could lead to the execution of `rm -rf /*` (however, the only way this
     could have happened would have been for the user to explicitly force this
     via the `--tmpdir` option, via `--tmpdir ""` or so, which seems unlikely
     to be entered by accident -- but not impossible)

- 2017-08-21
   - Fix detection of uncommitted changes

- 2017-02-05:
  - Fix copying htm directory into gh-pages branch (for packages using gapmacro)
  - Adjust HTML links in gh-pages to point to GAP manuals on the GAP website

- 2017-02-02:
  - Fix problem where an interactive `InstallAtExit` handler could get the
    `release` script stuck
  - After a successful run of the `release` script, display a reminder to run
    the online package validator, and show the `PackageInfo.g` URL to help
    with that.

...
