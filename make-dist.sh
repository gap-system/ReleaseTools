#!/bin/sh -e
#
# This script generates a .tar.gz, .tar.bz2 and .zip for a GAP package.
# This requires that a tag has been set of the form "v3.1". You then
# may invoke this script like this:
#    ./make_dist.sh PKGNAME 3.1
# and the rest happens automatically.
# If a checkout of the website repository is present, this script
# also copies relevant files (PackageInfo.g, documentation) there.

if [ $# -lt 2 ]; then
    echo "Usage: $0 <package> <version> [<tag-or-date>]"
    exit 1
fi

PKG=$1
VER=$2
if [ $# -lt 3 ]; then
    REF=v$VER  # a 'tag' by default, but allow overriding it
else
    REF=$3
fi

FULLPKG="$PKG-$VER"

SRC_DIR="$PWD"
DEST_DIR="$PWD/tmp/"
#DEST_DIR=/tmp
# TODO: allow overriding web dir location via command line switch
#WEB_DIR="$SRC_DIR/$PKG.gh-pages"
WEB_DIR="$SRC_DIR/gh-pages"

# Clean any remains of previous export attempts
mkdir -p "$DEST_DIR"
rm -rf "$DEST_DIR"/$FULLPKG*

echo "Exporting repository content for ref '$REF'"
if [ -d .git ] ; then
    git archive --prefix=$FULLPKG/ $REF | tar xf - -C "$DEST_DIR/"
elif [ -d .hg ] ; then
    hg archive  -r $REF "$DEST_DIR/$FULLPKG"
else
    echo "Error, only git and mercurial repositories are currently supported"
    exit 1
fi

echo "Removing unnecessary files"
cd "$DEST_DIR/$FULLPKG"
rm -f .git* .hg* .cvs*

if [ -x autogen.sh ] ; then
    echo "Generating build system files"
    sh autogen.sh
fi

# Build documentation and later remove aux files created by this.
echo "Building GAP package documentation"
gap -A makedoc.g #> /dev/null 2> /dev/null
rm -f doc/*.{aux,bbl,blg,brf,idx,ilg,ind,lab,log,out,pnr,tex,toc,tst}

echo "Creating tarball $FULLPKG.tar"
cd "$DEST_DIR"
tar cf $FULLPKG.tar $FULLPKG

echo "Compressing (using gzip) tarball $FULLPKG.tar.gz"
gzip -9c $FULLPKG.tar > $FULLPKG.tar.gz

echo "Compressing (using bzip2) tarball $FULLPKG.tar.gz"
bzip2 -9c $FULLPKG.tar > $FULLPKG.tar.bz2

echo "Zipping $FULLPKG.zip..."
zip -r9 --quiet $FULLPKG.zip $FULLPKG


# Update website repository if available
if [ -d $WEB_DIR ] ; then
    echo "Updating website"
    cd "$WEB_DIR"
    cp "$DEST_DIR/$FULLPKG/README" .
    cp "$DEST_DIR/$FULLPKG/PackageInfo.g" .
    rm -rf doc/
    mkdir -p doc/
    cp "$DEST_DIR/$FULLPKG/doc"/*.{css,html,js,txt} doc/
    cp "$DEST_DIR/$FULLPKG/doc/manual.pdf" doc/
    gap update.g
fi

echo "Done:"
cd $DEST_DIR
ls -l $FULLPKG.tar.gz $FULLPKG.tar.bz2 $FULLPKG.zip

exit 0
