# Use legacy bundle on high-sierra
if [ "x${OSTYPE:6:1}" = "x1" ]; then
bottle="https://github.com/autobrew/bundler/releases/download/cairo-1.16.0_5/cairo-1.16.0-high_sierra.tar.xz"
else
bottle="https://github.com/autobrew/bundler/releases/download/cairo-1.16.0_5/cairo-1.16.0_5-universal.tar.xz"
EXTRALIBS="-llzo2"
fi

# Skip if disabled
if [ "$DISABLE_AUTOBREW" ]; then return 0; fi
echo "Using autobrew bundle: $(basename $bottle)"

# General setup
BREWDIR="$PWD/.deps"
mkdir -p $BREWDIR
curl -sSL $bottle -o libs.tar.xz
tar -xf libs.tar.xz --strip 1 -C $BREWDIR
rm -f libs.tar.xz
rm -f $BREWDIR/lib/libpng.a

# pkg-config --libs-only-l --static cairo
PKG_LIBS="-L$BREWDIR/lib -lcairo -lpixman-1 -lfontconfig -lexpat -lfreetype -lbz2 -lpng16 $EXTRALIBS -lz"
PKG_CFLAGS="-I$BREWDIR/include -I$BREWDIR/include/cairo -I$BREWDIR/include/freetype2"

# Fix broken -lpng symlink for unigd pkg
cp -f $BREWDIR/lib/libpng16.a $BREWDIR/lib/libpng.a

# Prevent CRAN builder from linking against old libs in /usr/local/lib
for FILE in $BREWDIR/lib/*.a; do
  BASENAME=$(basename $FILE)
  LIBNAME=$(echo "${BASENAME%.*}" | cut -c4-)
  cp $FILE $BREWDIR/$LIBNAME
  PKG_LIBS=$(echo $PKG_LIBS | sed "s|-l$LIBNAME |../.deps/$LIBNAME |g")
done


# Cleanup
echo "rm -Rf .deps" >> cleanup
chmod +x cleanup
