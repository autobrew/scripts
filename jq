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
PKG_LIBS="-L$BREWDIR/lib -ljq -lonig -lz"

# Prevent CRAN builder from linking against old libs in /usr/local/lib
for FILE in $BREWDIR/lib/*.a; do
  BASENAME=$(basename $FILE)
  LIBNAME=$(echo "${BASENAME%.*}" | cut -c4-)
  mv $FILE $BREWDIR/$LIBNAME
  PKG_LIBS=$(echo $PKG_LIBS | sed "s|-l$LIBNAME |../.deps/$LIBNAME |g")
done

# Cleanup
echo "rm -Rf .deps" >> cleanup
chmod +x cleanup
