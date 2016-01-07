# ReleaseTools for GAP packages

The scripts in this repository along with this README are meant to help
GAP package authors with the process of making new releases of their
packages. The problem with making releases is that it is quite easy to
forget steps, which can cause a lot of extra work if you later need to
correct that. Moreover, if one only makes a release once a year, it is
easy to forget how this works -- making the release process an often
unwelcome and tiresome process.

The goal of this document and the tools shipped with it is to help GAP
package authors to automate this process as much as possible, so that
making a fresh release of a package becomes a quick and painless
undertaking.

These tools are for now focused on making releases for packages
hosted on GitHub, and which are using the GitHub release system
as well as GitHub pages for the package homepage.


## Initial setup
The following steps should be performed once on your package repository.
After that, you can follow the instructions in the next section to
make a release.

1. Make sure your package source code is hosted on GitHub, say under
   https://github.com/USER/FOOBAR where FOOBAR is the name of your package.
   We will from now on refer to `USER/FOOBAR` as the "repository" of your
   package.

2. Setup [GitHubPagesForGAP][] for your package, as described in its README.

3. Adjust your `PackageInfo.g` file to use GitHub. This may require adjusting
   `PackageWWWHome`, `README_URL`, `PackageInfoURL`, `ArchiveURL`. An easy
   way to do that is to use the following in your `PackageInfo.g`,
   where you should replace `FOOBAR` with the name of your package.

    ```
    PackageWWWHome := "http://gap-packages.github.io/FOOBAR/",
    README_URL     := Concatenation(~.PackageWWWHome, "README"),
    PackageInfoURL := Concatenation(~.PackageWWWHome, "PackageInfo.g"),
    ArchiveURL     := Concatenation("https://github.com/gap-packages/FOOBAR/",
                                    "releases/download/v", ~.Version,
                                    "/FOOBAR-", ~.Version),
    ```

4. Make sure to also update your README, you package manual etc. to
   use the correct URLs.

5. Optionally: Provide a `makedoc.g` which regenerates your package manual.
   If you are using GAPDoc, often the AutoDoc package provides an easy way
   for doing this, as in the following example (however, you do not
   have to use AutoDoc for this at all):

   ```
   LoadPackage("AutoDoc", "2014.03.27");
   SetPackagePath("FOOBAR", ".");
   AutoDoc("FOOBAR");
   QUIT;
   ```


## The release process

Suppose we want to release version 1.2.3 of a package named `FOOBAR`.
Suppose furthermore that directory `foo` contains a clone of the
repository.

1. Make sure we are on the right branch and have the latest version.

    ```
    cd foo && git checkout master && git pull
    ```

   You should also verify that there are no uncommitted local changes,
   and if there are, either commit them or remove them.

3. Update the version and release date in `PackageInfo.g`.

4. If you *are not* using AutoDoc to generating the title page of your
   package manual, also adjust the release date and version in your manual
   (typically this means `doc/FOOBAR.xml`).

   If you *are* using AutoDoc for this, make sure to run it now:

   ```
   gap -A makedoc.g
   ```

5. Make sure that any other files containing the version and release date
   are updated (e.g. a `CHANGES` with release notes).

6. Commit all your changes to `PackageInfo.g`, `VERSION`, documentation, etc., e.g.:

   ```
   git commit --all -m "Version 1.2.3"
   ```

7. Tag the release (this is required for the GitHub release system), and push
   your changes

    ```
    git tag v1.2.3
    git push
    ```

   Note: By default, ReleaseTools assume tag names of the form `vVERSION`.
   You can override this, if you want, but we recommend using the default.

8. Create the release using the `release` script included here:

    ```
    PATH/TO/ReleaseTools/release
    ```

   If this does not work, please refer to the section discussing `release`.

9. Verify that everything went fine by visiting
   https://github.com/USER/FOOBAR/releases/tag/v1.2.3 and
   https://USER.github.com/FOOBAR

   In particular, test the release archives created by the previous step. If you are unhappy
   with the outcome, or for some other reason decide that you need
   more changes, do these and go back and repeat previous steps
   as necessary (in step 7, you now need to pass "--force" to `git tag`,
   `git push` and the `release` tool)

10. Update the website:

    ```
    cd gh-pages && git push
    ```

    Note that `release` will also do this for you if you call it with
    the `--push` option.


That's it. You should now be able to see the new version on
  https://USER.github.com/FOOBAR
and also be able to view the manual there, download the new version
etc. Moreover
  https://USER.github.com/FOOBAR/PackageInfo.g
should be up-to-date. So if the GAP server already has this registered
as location of your `PackageInfo.g`, it should now automatically
detect that you made a release, and pull it into the next
GAP package bundle.


### The release script

This tool helps you create release archives of your GAP package in a clean
and controlled way, and publish them on GitHub.

Again, we assume you are working on version 1.2.3 or package `FOOBAR`.

#### Invoking the release script

You normally invoke `release` as follows from inside a clone of your
package repository:

```
PATH/TO/ReleaseTools/release
```

This scans your `PackageInfo.g` for the package name and version, and
uses that to guess the release tag.

By default, the script assumes that you tagged your release with a tag named
`vVERSION` (so `v1.2.3` in our example). If you prefer to use other
tag names, you can specify this as parameter, e.g.

```
PATH/TO/ReleaseTools/release --tag VER-1-2-3
```

Note that the `release` tool will attempt to verify your tag by checking
it against the `ArchiveURL` in your `PackageInfo.g`.

TODO: describe other options


#### What it does


The `release` script does multiple things for you:

1. It creates archive files in a subdirectory `tmp` of the current directory.
   For now, it knows how to create `.tar.gz`, `.tar.bz2` and `.zip` files.
   Which it creates depends on the `ArchiveFormats` field of your `PackageInfo.g`.

   The files by default are `tmp/PACKAGENAME-VERSION.tar.gz` etc., so in
   our example we would get
   * `tmp/FOOBAR-1.2.3.tar.gz`
   * `tmp/FOOBAR-1.2.3.tar.bz2`
   * `tmp/FOOBAR-1.2.3.zip`

   However, the script also look at the `ArchiveURL` field of your `PackageInfo.g`
   to decide if a different basename was chosen. So if you prefer the archives
   to be called

   * `tmp/foobar-1.2.3.tar.gz`
   * `tmp/foobar-1.2.3.tar.bz2`
   * `tmp/foobar-1.2.3.zip`

   then you can achieve this by editing your  `PackageInfo.g`.

   To create these archives, `release` uses `git archive`
   to export precisely the files in your repository present in the commit
   tagged `v1.2.3`. This ensures
   that *only* files that are present in your repository will be added,
   no more, no less; and that no stray local changes are included by accident.

   After exporting all files, a few more steps are performed:
   a. It removes any `.gitignore`, `.gitmodules` files.
   b. If a script `autogen.sh` is present, it is executed.
   c. If a file `makedoc.g` is present, it is executed.
      Various files like `doc/*.aux` are removed afterwards.


2. It uploads the created files to GitHub for you.
   
   TODO: Describe details


3. It updates various files in the `gh-pages` subdirectory to help you with
   updating the website. In particular, it copies the `PackageInfo.g` and
   `README` to `gh-pages`, and also copies the HTML version of the manual it
   just built for the release archives to `gh-pages/doc`.
   Finally, it runs the `update.g` script to regenerate `gh-pages/_data/package.yml`.



## GitHub access token

The `release` script needs limited write access to your repository in
order to upload the release archives for you. For this, you need to
generate a so-called GitHub access token. To generate one, please follow
the instructions on
 https://help.github.com/articles/creating-an-access-token-for-command-line-use

When creating the token, you will have to select which "scopes" it is for.
The only scope needed by the `release` scrips it the `repo` scope.


## Packages using the ReleaseTools

Packages that are (mostly) following the release process outlined here
include the following:

* https://github.com/gap-package/cvec
* https://github.com/gap-package/genss
* https://github.com/gap-package/io
* https://github.com/gap-package/nq
* https://github.com/gap-package/orb
* https://github.com/gap-package/polenta
* https://github.com/gap-package/recog
* https://github.com/gap-package/recogbase


## TODO

- talk about design goals, in particular: encoding information in as few places as possible.
- talk about using GitHub releases system
- talk about https://github.com/fingolfin/GitHubPagesForGAP
- update https://github.com/fingolfin/PackageMaker to (optionally?)
  set up everything for this process
- explain which access "scope" the GitHub access token needs
- ...


## Contact

Please submit bug reports, suggestions for improvements and patches via
the [issue tracker](https://github.com/fingolfin/ReleaseTools/issues).

You can also contact me directly via [email](max@quendi.de).

Copyright (c) 2013-2016 Max Horn

[GitHubPagesForGAP]: https://github.com/fingolfin/GitHubPagesForGAP
