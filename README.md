ReleaseTools for GAP packages
=============================

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


Initial setup
=============
The following steps should be performed once on your package repository.
After that, you can follow the instructions in the next section to
make a release.


TODO:

- talk about encoding information in as few places as possible. Ideally
  things like the version and release date should be in a single spot,
  which has to be changed for a release, all other references to them
  should be generated from that spot.
  Talk about ways to achieve that.
  Mention AutoDoc as a useful helper
- talk about using GitHub releases system
- talk about https://github.com/fingolfin/GitHubPagesForGAP
- update https://github.com/fingolfin/PackageMaker to (optionally?)
  set up everything for this process
- ...


# The release process
Suppose we want to release version 1.2.3 of a package named `FOO`.
Suppose furthermore that director `foo` contains a clone of the
repository.

1. Make sure we are on the right branch and have the latest version.
   
    ```
    cd foo && git checkout master && git pull
    ```

   You should also verify that there are no uncommitted local changes,
   and if there are, either commit them or remove them.

2. If you are using [GitHubPagesForGAP][], make sure the `gh-pages`
   subdirectory exists and is up-to date.

    ```
    cd gh-pages && git pull && cd ..
    ```

2. Update version and release date in `PackageInfo.g`.

3. If you are *not* using AutoDoc to generating the title page of your
   package manual, also adjust the release date and version in your manual
   (typically this means `doc/FOO.xml`).

4. Make sure that any other files containing the version and release date
   are updated (e.g. a `CHANGES` with release notes).

5. Build the documentation:

   ```
   gap -A makedoc.g
   ```

   If you followed the instructions from the previous section, this should
   also take care of updating the version information in other files
   (like the VERSION file, your manual, your `configure` script etc.)

6. Commit a changes to `PackageInfo.g`, `VERSION`, manual, etc.:

   ```
   git commit -all -m "Version 1.2.3"
   ```

7. Tag the release:

    ```
    git tag v1.2.3
    ```

8. Create the release archives using the `make-dist` script included here:

    ```
    PATH/TO/ReleaseTools/make-dist
    ```
   
   If this does not work, please refer to the section discussing `make-dist`. 

9. Test the release archives created by the previous step. If you are unhappy
   with the outcome, or for some other reason decide that you need
   more changes, do these and go back and repeat previous steps
   as necessary (in step 7, you now need to pass "-f" to "git tag"
   to force it to move the tag).

10. If you are happy with everything, push your changes out, including the new
    tag, to the GitHub.

    ```
    git push master --tags
    ```

11. Now upload the archives to GitHub. You can do this manually, but we also
    include an `upload` script to do this for you:

    ```
    PATH/TO/ReleaseTools/upload --tag v1.2.3 --repo FOO tmp/foo-1.2.3.*
    ```
    
    For this to work, you need to first setup a GitHub token etc.,
    please refer to the section discussing the `upload` script.

12. Verify that everything went fine by visiting
     https://github.com/USER/FOO/releases/tag/v1.2.3

13. Update the website.

    ```
    cd gh-pages && git commit --all -m "Update website for version 1.2.3" && git push
    ```

That's it. You should now be able to see the new version on 
  https://USER.github.com/FOO
and also be able to view the manual there, download the new version
etc. Moreover  
  https://USER.github.com/FOO/PackageInfo.g
should be up-to-date. So if the GAP server already has this registered
as location of your PackageInfo.g, it should now automatically
detect that you made a release, and pull it into the next
GAP package bundle.


## The make_dist script

This tool helps you create release archives of your GAP package in a clean
and controlled way. 

Again, we assume you are working on version 1.2.3 or package `FOO`.

### Invoking the make_dist script

You normally invoke `make_dist` as follows from inside a clone of your
package repository (only Git and Mercurial repositories are supported
right now):

```
PATH/TO/ReleaseTools/make-dist
```

This scans your PackageInfo.g for the package name and version, and
uses that to guess the release tag. However, this scanning is rather
simplistic and may fail. Therefore you can also specify the package
name and version explicitly:

```
PATH/TO/ReleaseTools/make-dist FOO 1.2.3
```
    
By default, the script assumes that you tagged your release with a tag named
`vVERSION` (so `v1.2.3` in our example). If you prefer to use other
tag names, you can specify these as third parameter, e.g.

```
PATH/TO/ReleaseTools/make-dist FOO 1.2.3 VER-1-2-3
```

You can even use it without any tags, and specify any commit or branch
name as third parameter (in GIT parlance, any `committish` will do), e.g.

```
PATH/TO/ReleaseTools/make-dist FOO 1.2.3 master
```

However, I strongly recommend using a tag, as that makes it much easier
for you and others to later replicate the release process and verify
that the release archive contains exactly what it should contain.


### What it does

   
The `make-dist` script does two things for you:

1. It creates archive files in a subdirectory `tmp` of the current directory.
   For now, this always includes a `.tar.gz`, a `.tar.bz2` and a `.zip`.
   In the future, this may become configurable, and more formats could
   be added.
   
   The files will be named `tmp/PACKAGENAME-VERSION.tar.gz` etc., so in
   our example we would get
   * `tmp/foo-1.2.3.tar.gz`
   * `tmp/foo-1.2.3.tar.bz2`
   * `tmp/foo-1.2.3.zip`

   To create these archives, `make-dist` uses `git archive` or `hg archive`
   to export precisely the files in your repository present in the commit
   tagged `v1.2.3`. This ensures
   that *only* files that are present in your repository will be added,
   no more, no less; and that no stray local changes are included by accident.
   (Note: )
   
   After exporting all files, a few more steps are performed:
   a. It removes any `.gitignore`, `.gitmodules` files.
   b. If a script `autogen.sh` is present, it is executed.
   c. If a file `makedoc.g` is present, it is executed using `gap -A makedoc.g`.
      Various files like `doc/*.aux` are removed afterwards.
   

2. It updates various files in the `gh-pages` subdirectory to help you with
   updating the website. In particular, it copies the `PackageInfo.g` and
   `README` to `gh-pages`, and also copies the HTML version of the manual it
   just built for the release archives to `gh-pages/doc`.
   Finally, it runs the `update.g` script to regenerate `gh-pages/_data/package.yml`.



## The upload script

The perl script `upload` can be used to automatically upload release archives
of your package (e.g. created via `make_dist`) to GitHub. 


### Initial setup

It has some prerequisites, which you can install e.g. via CPAN:

  ```
  cpan install Pithub Getopt::Long::Descriptive File::Type
  ```

Moreover, to use it, the script needs to know how to access
your repository, and it must have the correct access permissions
to be allowed to upload files under your name. A naive way
to do that would be to tell it your GitHub password. But trusting
a script with a password is a bit risky, so instead, a
so-called `access token` is used. To generate one, follow
the steps described on 
 https://help.github.com/articles/creating-an-access-token-for-command-line-use

TODO:

- explain which access "scope" the token needs
- explain how to store the user and token via `git config github.user VALUE`
  and  `git config github.token VALUE`
-

  
### Invoking the upload script

TODO:

- describe all parameters: -f/--force, --token, --user, ...
- ...


### What it does

TODO:

- creates release for the given tag, optionally sets description text loaded from file (e.g. from `CHANGES` file), then uploads archives.
- if this fails or you are unhappy, start over (needs `--force` option -- or perhaps change it and provide a --delete option? or ...?)



# Packages using the ReleaseTools
Packages that are (mostly) following the release process outlined here
include the following:

* https://github.com/neunhoef/cvec
* https://github.com/neunhoef/io
* https://github.com/neunhoef/genss
* https://github.com/neunhoef/orb
* https://github.com/neunhoef/recog
* https://github.com/neunhoef/recogbase
* https://github.com/gap-system/nq
* https://github.com/gap-system/polenta


# Feedback

Please submit bug reports, suggestions for improvements and patches via
the [issue tracker](https://github.com/fingolfin/ReleaseTools/issues).

You can also contact me directly via [email](max@quendi.de).




[GitHubPagesForGAP]: https://github.com/fingolfin/GitHubPagesForGAP

