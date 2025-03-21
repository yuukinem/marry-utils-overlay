# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson vala

DESCRIPTION="Core library for Astal widgets"
HOMEPAGE="https://github.com/aylur/astal"
SRC_URI="https://github.com/aylur/astal/archive/refs/heads/main.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/astal-main/lib/astal/io"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/glib:2
	dev-libs/gobject-introspection
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	$(vala_depend)
"

src_prepare() {
	default
	vala_setup

	# Create needed symlinks (Gentoo-specific)
	if [ ! -e /usr/bin/valac ]; then
		ln -sf $(which valac-$(vala_best_api_version)) /usr/bin/valac || die
	fi
	if [ ! -e /usr/bin/valadoc ]; then
		ln -sf $(which valadoc-$(vala_best_api_version)) /usr/bin/valadoc || die
	fi
	if [ ! -e /usr/bin/vapigen ]; then
		ln -sf $(which vapigen-$(vala_best_api_version)) /usr/bin/vapigen || die
	fi
}

src_install() {
	meson_src_install
}

pkg_postinst() {
	elog "Astal IO has been installed successfully."
}
