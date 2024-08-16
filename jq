# Use legacy bundle on high-sierra
if [ "x${OSTYPE:6:1}" = "x1" ]; then
bottle="https://github.com/autobrew/bundler/releases/download/jq-1.6/jq-1.6-high_sierra.tar.xz"
else
bottle="https://github.com/autobrew/bundler/releases/download/jq-1.6/jq-1.6-universal.tar.xz"
fi

# Skip if disabled
if [ "$DISABLE_AUTOBREW" ]; then return 0; fi
echo "Using autobrew bundle: $(basename $bottle)"

# Skip if disabled
if [ "$DISABLE_AUTOBREW" ]; then return 0; fi

# General setup
BREWDIR="$PWD/.deps"
mkdir -p $BREWDIR
curl -sSL $bottle -o libs.tar.xz
tar -xf libs.tar.xz --strip 1 -C $BREWDIR
rm -f libs.tar.xz

# package may look under /opt
mkdir -p $BREWDIR/opt/jq
ln -s $BREWDIR/{include,lib} $BREWDIR/opt/jq/

# Hardcoded flags
PKG_CFLAGS="-I$BREWDIR/include"
PKG_LIBS="-L$BREWDIR/lib -ljq -lonig"

# Cleanup
echo "rm -Rf .deps" >> cleanup
chmod +x cleanup

# Disable vignettes on oldrel due to https://github.com/yihui/knitr/issues/2338
if [ "${R_VERSION:0:3}" = "4.3" ]; then
  echo '1+1' > inst/doc/*.R || true
fi
