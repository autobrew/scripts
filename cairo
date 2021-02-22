# Find a bundle
if [ $(arch | grep arm) ]; then
bottle="https://autobrew.github.io/archive/arm64_big_sur/cairo-1.16.0-arm64_big_sur.tar.xz"
EXTRALIBS="-llzo2"
elif [[ ${OSTYPE:6} -ge 20 ]]; then
bottle="https://autobrew.github.io/archive/big_sur/cairo-1.16.0-big_sur.tar.xz"
EXTRALIBS="-llzo2"
elif [[ ${OSTYPE:6} -ge 17 ]]; then
bottle="https://autobrew.github.io/archive/high_sierra/cairo-1.16.0-high_sierra.tar.xz"
else
bottle="https://autobrew.github.io/archive/el_capitan/cairo-1.16.0-el_capitan.tar.xz"
fi

# Skip if disabled
if [ "$DISABLE_AUTOBREW" ]; then return 0; fi

# General setup
BREWDIR="$PWD/.deps"
mkdir -p $BREWDIR
curl -sSL $bottle -o libs.tar.xz
tar -xf libs.tar.xz --strip 1 -C $BREWDIR
rm -f libs.tar.xz

# pkg-config --libs-only-l --static cairo
PKG_LIBS="-L$BREWDIR/lib -lcairo -lpixman-1 -lfontconfig -lexpat -lfreetype -lbz2 -lpng16 -lz $EXTRALIBS"
PKG_CFLAGS="-I$BREWDIR/include -I$BREWDIR/include/cairo -I$BREWDIR/include/freetype2"

# Prevent CRAN builder from linking against old libs in /usr/local/lib
for FILE in $BREWDIR/lib/*.a; do
  BASENAME=$(basename $FILE)
  LIBNAME=$(echo "${BASENAME%.*}" | cut -c4-)
  cp -f $FILE $BREWDIR/lib/libbrew$LIBNAME.a
  PKG_LIBS=$(echo $PKG_LIBS | sed "s/-l$LIBNAME /-lbrew$LIBNAME /g")
done

# Cleanup
echo "rm -Rf .deps" >> cleanup
chmod +x cleanup
