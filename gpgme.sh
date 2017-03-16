echo "Auto-brewing $PKG_BREW_NAME..."
BREWDIR="$TMPDIR/homebrew"
BREW="$BREWDIR/bin/brew"
rm -Rf $BREWDIR
mkdir -p $BREWDIR
mkdir -p inst/bin
curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $BREWDIR
BREW_DEPS=$($BREW deps -n $PKG_BREW_NAME)
HOMEBREW_CACHE="/tmp" $BREW install --force-bottle $BREW_DEPS $PKG_BREW_NAME gnupg 2>&1 | perl -pe 's/Warning/Note/gi'
PKG_CFLAGS=$($BREWDIR/opt/$PKG_BREW_NAME/bin/gpgme-config --cflags)
PKG_LIBS=$($BREWDIR/opt/$PKG_BREW_NAME/bin/gpgme-config --libs)

# Ship a standalone 'gpg'
cp -f $BREWDIR/opt/gnupg/bin/gpg1 inst/bin/gpg

# Build and ship a standalone pinentry
rm -f $BREWDIR/Cellar/libassuan/*/lib/*.dylib
rm -f $BREWDIR/Cellar/libgpg-error/*/lib/*.dylib
HOMEBREW_CACHE="/tmp" $BREWDIR/bin/brew reinstall pinentry --build-from-source
cp -f $BREWDIR/opt/pinentry/bin/pinentry inst/bin/pinentry

# Just to be sure
rm -f $BREWDIR/Cellar/*/*/lib/*.dylib
