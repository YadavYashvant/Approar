# Maintainer: Your Name <your.email@example.com>
pkgname=approar
pkgver=1.0.0
pkgrel=1
pkgdesc="Tool to build, install and run Android apps with USB debugging"
arch=('any')
url="https://github.com/YadavYashvant/Approar"
license=('MIT')
depends=('android-tools' 'gradle')
source=("run-android-app.sh")
sha256sums=('SKIP')

package() {
    install -Dm755 "$srcdir/run-android-app.sh" "$pkgdir/usr/bin/run-android-app"
} 