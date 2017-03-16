BREWDIR="$TMPDIR/homebrew"
rm -Rf $BREWDIR
mkdir -p $BREWDIR
echo "Auto-brewing $PKG_BREW_NAME in $BREWDIR..."
curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $BREWDIR
HOMEBREW_CACHE="/tmp" $BREWDIR/bin/brew install --force-bottle $PKG_BREW_NAME 2>&1 | perl -pe 's/Warning/Note/gi'
rm -f $BREWDIR/Cellar/$PKG_BREW_NAME/*/lib/*.dylib
rm -f $BREWDIR/opt/$PKG_BREW_NAME/lib/*.dylib
