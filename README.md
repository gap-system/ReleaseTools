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

These tools are focused on making releases for packages hosted on
GitHub, and which are using the GitHub release system as well as GitHub
pages for the package homepage.

Please try to always use the latest version of this tool. You can
obtain it from <https://github.com/gap-system/ReleaseTools>.


## Requirements

The `release-gap-package` script should run on any POSIX compatible system,
provided the following tools are available:

* [curl](https://curl.haxx.se/)
* git
* Python 2.6 or later
* BSD or GNU tar (for creating `.tar.gz` and `.tar.bz2` archives)
* zip (for creating `.zip` archives; only needed if your `PackageInfo.g`
  specifies it in the `ArchiveFormats` field)

In addition, you also need a recent enough version of GAP (4.7.8 or later
should do it). By default the `release-gap-package` script assumes that there is a
`gap` executable in your PATH. If this is not the case, or if you want
`release-gap-package` to use another GAP executable, you can do so via the `GAP`
environment variable.

For example, you could invoke `release-gap-package` like this, assuming the
`ReleaseTools` directory is next to your package's directory:

    GAP=/home/john_smith/gap/bin/gap.sh  ../ReleaseTools/release-gap-package

Your package must also be hosted on GitHub.

Finally, you need a GitHub access token, which the script uses to authenticate
with GitHub, so that it gets permission to upload files for you. For details,
please read section "GitHub access token" later in this README.


## Initial setup

The following steps should be performed once on your package repository.
After that, you can follow the instructions in the next section to
make a release.

1. Setup [GitHubPagesForGAP][] for your package, as described in its README.

2. Adjust your `PackageInfo.g` file to use GitHub. This may require adjusting
   `PackageWWWHome`, `README_URL`, `PackageInfoURL`, `ArchiveURL`. An easy way
   to do that is to use the following in your `PackageInfo.g`. It assumes that
   your package name is equal to the repository name; note that case matters.
   Also, if your package repository is not hosted in the `gap-packages` GitHub
   organization, you need to replace the string `gap-packages` in
   `SourceRepository.URL` and `PackageWWWHome` by your GitHub username.

    ```
    SourceRepository := rec(
        Type := "git",
        URL := Concatenation( "https://github.com/gap-packages/", ~.PackageName ),
    ),
    IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
    PackageWWWHome  := Concatenation( "https://gap-packages.github.io/", ~.PackageName ),
    README_URL      := Concatenation( ~.PackageWWWHome, "/README" ),
    PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
    ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                     "/releases/download/v", ~.Version,
                                     "/", ~.PackageName, "-", ~.Version ),
    ```

3. Update your README, your package manual etc. to use these URLs.

4. Provide a `makedoc.g` GAP file which regenerates your package manual.
   If you are using GAPDoc, often the AutoDoc package provides an easy way
   for doing this, as in the following example:

   ```
   if fail = LoadPackage("AutoDoc", "2016.02.16") then
       Error("AutoDoc version 2016.02.16 or newer is required.");
   fi;
   AutoDoc();
   ```

   As a fallback, we also looks for a `doc/make_doc` executable.
   If found, we assume the package is not using GAPDoc, but rather
   still uses a manual based on the `gapmacro` TeX macros. We then
   execute the `make_doc` script from inside the `doc` directory,
   and copy relevant files.


## The release process (short version)

The following assumes that you have the latest version of the `release-gap-package`
script from <https://github.com/gap-system/ReleaseTools> on your computer.

1. Prepare your release, commit all changes and push them

2. Run `PATH/TO/ReleaseTools/release-gap-package`

3. If there was no error, you are done. Otherwise, address the error,
   commit and push the changes, then repeat step 2 (you may need to add
   the `--force` option, to convince `release-gap-package` to re-create git tags
   etc.)


## The release process (extended version)

The following assumes that you have the latest version of the `release-gap-package`
script from <https://github.com/gap-system/ReleaseTools> on your computer.

Suppose we want to release version 1.2.3 of a package named `FOOBAR`.
Suppose furthermore that directory `foo` contains a clone of the
repository.

In order to make a release, you can follow the steps below. Note that this
assumes that `gap` is in your PATH, i.e. it can be invoked by just entering
`gap`. Alternatively, before running the `release-gap-package` tool you can
set the `GAP` environment variable to contain the full path to your GAP
executable.

1. Make sure we are on the right branch and have the latest version.

    ```
    cd foo && git checkout master && git pull
    ```

   You should also verify that there are no uncommitted local changes,
   and if there are, either commit them or remove them.

2. Make sure there is a `gh-pages` subdirectory in `foo` which contains an up-to-date checkout
   of the `gh-pages` branch of your repository.
   
    ```
    cd gh-pages && git checkout gh-pages && git pull && cd ..
    ```

   If there is no `gh-pages` directory. resp. no `gh-pages` branch, you need
   to create one as described in the README of [GitHubPagesForGAP][].

3. Update the version and release date in `PackageInfo.g`.

4. Adjust the release date and version in your manual. Note that AutoDoc can do this
   automatically for you (please consult its manual to learn more).

5. Make sure that all files containing the version and release date
   are updated (e.g. the manual; your `CHANGES` or `VERSION` files, etc.).

6. Commit all your changes to `PackageInfo.g`, `VERSION`, documentation, etc., e.g.:

   ```
   git commit --all -m "Version 1.2.3"
   ```

7. Create the release using the `release-gap-package` script included here:

    ```
    PATH/TO/ReleaseTools/release-gap-package --no-push
    ```

   If this does not work, please refer to the section discussing `release`.

8. Verify that everything went fine by visiting
   <https://github.com/USER/FOOBAR/releases/tag/v1.2.3> and
   <https://USER.github.io/FOOBAR>

   In particular, test the release archives created by the previous step. If
   you are unhappy with the outcome, or for some other reason decide that you
   need more changes, do these and go back and repeat previous steps as
   necessary (in step 7, you now need to pass `--force` to the
   `release-gap-package` tool)

9. Update the website:

    ```
    cd gh-pages && git push
    ```

    Note that `release-gap-package` will also do this for you if you omit the
    `--no-push` option; once you are familiar with this tool, and confident
    everything worked fine, you may want to always do it that way.


That's it. You should now be able to see the new version on
  <https://USER.github.io/FOOBAR>
and also be able to view the manual there, download the new version
etc. Moreover
  <https://USER.github.io/FOOBAR/PackageInfo.g>
should be up-to-date. So if the GAP server already has this registered
as location of your `PackageInfo.g`, it should now automatically
detect that you made a release, and pull it into the next
GAP package bundle.


## The `release-gap-package` script

The `release-gap-package` script helps you create release archives of your GAP
package in a clean and controlled way, and publish them on GitHub.

Again, we assume you are working on version 1.2.3 or package `FOOBAR`.

### Invoking the `release-gap-package` script

You normally invoke `release-gap-package` as follows from inside a clone of your
package repository:

    PATH/TO/ReleaseTools/release-gap-package

This scans your `PackageInfo.g` for the package name and version, and uses
that to guess the release tag, and continues from there (see the next section
for more details). However, several options can be passed to the
`release-gap-package` tool to adjust this process.

1. **Options which indicate actions:**

   - `-h`, `--help`: display a brief help text and exits

   - `-p`, `--push`: Perform the very last step in the release process,
     which is to update the website with the new release by running `git push`
     inside the `gh-pages` directory. This is the default.

   - `-P`, `--no-push`: The reverse of `--push`: Do not push the new release
     to the website. This gives you a chance to inspect all generated files
     etc. before finally making the new release public.

   - `-f`, `--force`: for safety reasons, `release-gap-package` will abort
   immediately if it thinks that a release with the same version number has
   already been made, e.g. because the tag for the release already exists.
   This is done because the GAP package distribution strongly advices against
   reusing the same version for different content. However, this check might
   be wrongly triggered, e.g. because an attempt to release the current
   version was aborted earlier due to another error. In this case, you can use
   the `--force` option to instruct `release-gap-package` to disable this check.

2. **Options which adjust paths:**

   - `--srcdir <path>`: Set the path of the directory containing `PackageInfo.g` to `<path>`.
     The default is to use the current directory.

   - `--tmpdir <path>`: Set the path of the temporary directory into which the
     archives are put before being uploaded. The default is to use the `tmp`
     subdirectory of the `srcdir`.

   - `--webdir <path>`: Set the path of the web directory which contains the `GitHubPagesForGAP`
     website. The default is to use the `gh-pages` subdirectory of the `srcdir`.

3. **Custom settings:**

   - `--token`: Set the GitHub token to use. For details, refer to section "GitHub access token"
     in this README.


### What the `release-gap-package` script does

The `release-gap-package` script does multiple things for you:

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

   To create these archives, `release-gap-package` uses `git archive`
   to export precisely the files in your repository present in the commit
   tagged `v1.2.3`. This ensures
   that *only* files that are present in your repository will be added,
   no more, no less; and that no stray local changes are included by accident.

   After exporting all files, a few more steps are performed:
   a. It removes any `.gitignore`, `.gitmodules` files.
   b. If a script `autogen.sh` is present, it is executed.
   c. If a file `makedoc.g` is present, it is executed.
      Various files like `doc/*.aux` are removed afterwards.
   d. Otherwise, if a file `doc/make_doc` is present, it is executed.
      Various files like `doc/*.aux` are removed afterwards.


2. It uploads the created files to GitHub for you.

   TODO: Describe details


3. It updates various files in the `gh-pages` subdirectory to help you with
   updating the website. In particular, it copies the `PackageInfo.g` and
   `README` to `gh-pages`, and also copies the HTML version of the manual it
   just built for the release archives to `gh-pages/doc`.
   Finally, it runs the `update.g` script to regenerate `gh-pages/_data/package.yml`.



## GitHub access token

The `release-gap-package` script needs limited write access to your repository
in order to upload the release archives for you. In order to do this, the
scripts needs to authenticate itself with GitHub, for which it needs a
so-called "personal access token". You can generate such a token as follows
(see also <https://help.github.com/articles/creating-an-access-token-for-command-line-use>).

1. Go to <https://github.com/settings/tokens>.

2. Click **Generate new token**.

3. Select the scope "public_repo", and give your token a descriptive name.

4. Click **Generate token** at the bottom of the page.

5. Copy the token to your clipboard. For security reasons, after you navigate
   off the page, you will not be able to see the token again. You therefore
   should store it somewhere, e.g. with option 3 in the following list.

There are multiple ways to tell the `release-gap-package` script what your token is.
In order of their precedence from lowest to highest:

1. **Recommended**: Create a file `~/.github_shell_token` containing your
   token and nothing else. If you do this, make sure this file is not readable
   by other users, i.e., run `chmod 0600 ~/.github_shell_token`.

2. Add the token to your git config, by setting `github.token`. As usual with
   git config entries, you can set this globally in your `~/.gitconfig` or
   locally for each clone (which can be handy if you need different tokens for
   different projects). You can set the token via the following commands
   (for details, please refer to `git help config`):

        git config github.token VALUE           # for the current project
        git config --global github.token VALUE  # globally

3. Set the environment variable `TOKEN` to the token value.
   This is mainly useful in scripts. E.g.

        TOKEN=VALUE ./release-gap-package ...

4. Use the `--token` command line option:

        ./release-gap-package --token VALUE ...


## Contact

Please submit bug reports, suggestions for improvements and patches via
the [issue tracker](https://github.com/gap-system/ReleaseTools/issues).

You can also contact me directly via [email](mailto:max@quendi.de).

Copyright (c) 2013-2020 Max Horn

[GitHubPagesForGAP]: https://github.com/gap-system/GitHubPagesForGAP
