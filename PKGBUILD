# Maintainer: Jean28518@Github

pkgname=linux-assistant
pkgver=0.5.3
pkgrel=1
pkgdesc='A daily linux helper with powerful integrated search, routines and checks.'
arch=('x86_64')
url='https://www.linux-assistant.org'
license=('GPL-3.0-or-later')
depends=('libkeybinder3'
        'wmctrl'
        'wget'
        'python'
        'mesa-utils'
        'polkit')
options=('!debug')
source=("https://github.com/Jean28518/linux-assistant/releases/latest/download/linux-assistant-bundle.zip")
sha256sums=('SKIP')

package() {
    cd linux-assistant-bundle

    install -Dm755 linux-assistant.sh "$pkgdir/usr/bin/linux-assistant"
    install -Dm644 org.linux-assistant.operations.policy "$pkgdir/usr/share/polkit-1/actions/org.linux-assistant.operations.policy"
    install -Dm644 linux-assistant.desktop "$pkgdir/usr/share/applications/linux-assistant.desktop"
    install -Dm644 linux-assistant.png "$pkgdir/usr/share/icons/hicolor/256x256/apps/linux-assistant.png"

    install -dm755 "$pkgdir/usr/lib/linux-assistant"
    cp -a lib "$pkgdir/usr/lib/linux-assistant/"
    cp -a data "$pkgdir/usr/lib/linux-assistant/"
    cp -a additional "$pkgdir/usr/lib/linux-assistant/"

    install -Dm644 version "$pkgdir/usr/lib/linux-assistant/version"
    install -Dm755 linux-assistant "$pkgdir/usr/lib/linux-assistant/linux-assistant"
}
