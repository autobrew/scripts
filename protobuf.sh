echo "Auto-brewing $PKG_BREW_NAME..."
BREWDIR="$TMPDIR/homebrew"
rm -Rf $BREWDIR
mkdir -p $BREWDIR
curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $BREWDIR
HOMEBREW_CACHE="/tmp" $BREWDIR/bin/brew install --force-bottle $PKG_BREW_NAME 2>&1 | sed 's/Warning/Note/g'

# 2017-03-15: there's a bug in protoc not finding dylibs
mv $BREWDIR/opt/$PKG_BREW_NAME/lib/*.dylib $BREWDIR/opt/$PKG_BREW_NAME/bin/
export DYLD_LIBRARY_PATH="$BREWDIR/opt/$PKG_BREW_NAME/bin"
