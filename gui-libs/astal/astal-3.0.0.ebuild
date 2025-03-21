# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson vala

DESCRIPTION="GTK3 widgets for Wayland"
HOMEPAGE="https://github.com/aylur/astal"
SRC_URI="https://github.com/aylur/astal/archive/refs/heads/main.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/astal-main/lib/astal/gtk3"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/astal-io
	dev-libs/glib:2
	dev-libs/gobject-introspection
	x11-libs/gtk+:3[introspection]
	gui-libs/gtk-layer-shell[introspection]
	dev-libs/wayland
	dev-libs/wayland-protocols
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

src_configure() {
	# Generate vapi file for gtk-layer-shell if not exists
	if [ ! -e /usr/share/vala/vapi/gtk-layer-shell-0.vapi ]; then
		mkdir -p "${T}/vapi" || die
		cd "${T}/vapi" || die
		vapigen --library=gtk-layer-shell-0 --pkg=gtk+-3.0 /usr/share/gir-1.0/GtkLayerShell-0.1.gir || die
		mkdir -p /usr/share/vala/vapi
		cp gtk-layer-shell-0.vapi /usr/share/vala/vapi/
	fi

	cd "${S}" || die
	meson_src_configure
}

src_install() {
	meson_src_install
}

pkg_postinst() {
	elog "Astal GTK3 widgets have been installed successfully."
}
