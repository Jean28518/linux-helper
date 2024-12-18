# Build bundle
VERSION="$( cat version )"

sed -i "s/pkgver=.*/pkgver=$VERSION/" PKGBUILD

makepkg -s
