# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson vala multilib

DESCRIPTION="GTK widgets for Wayland"
HOMEPAGE="https://github.com/aylur/astal"
SRC_URI="https://github.com/aylur/astal/archive/refs/heads/main.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/astal-main"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+gtk3 gtk4"

REQUIRED_USE="|| ( gtk3 gtk4 )"

RDEPEND="
	dev-libs/astal-io
	dev-libs/glib:2
	dev-libs/gobject-introspection
	gtk3? (
		x11-libs/gtk+:3[introspection]
		gui-libs/gtk-layer-shell[introspection]
	)
	gtk4? (
		gui-libs/gtk4[introspection]
		gui-libs/gtk4-layer-shell[introspection]
	)
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
	if use gtk3; then
		# Generate vapi file for gtk-layer-shell if not exists
		if [ ! -e /usr/share/vala/vapi/gtk-layer-shell-0.vapi ]; then
			mkdir -p "${T}/vapi" || die
			cd "${T}/vapi" || die
			vapigen --library=gtk-layer-shell-0 --pkg=gtk+-3.0 /usr/share/gir-1.0/GtkLayerShell-0.1.gir || die
			mkdir -p /usr/share/vala/vapi
			cp gtk-layer-shell-0.vapi /usr/share/vala/vapi/
		fi
		
		einfo "Configuring GTK3 version"
		local gtk3_builddir="${WORKDIR}/gtk3-build"
		meson setup \
			--prefix="${EPREFIX}/usr" \
			--libdir="$(get_libdir)" \
			--buildtype=plain \
			--wrap-mode=nodownload \
			-Db_lto=false \
			-Db_pch=false \
			-Dwerror=false \
			${gtk3_builddir} \
			"${S}/lib/astal/gtk3" || die "GTK3 setup failed"
	fi
	
	if use gtk4; then
		# Generate vapi file for gtk4-layer-shell if not exists
		if [ ! -e /usr/share/vala/vapi/gtk4-layer-shell-0.vapi ]; then
			mkdir -p "${T}/vapi" || die
			cd "${T}/vapi" || die
			vapigen --library=gtk4-layer-shell-0 --pkg=gtk4 /usr/share/gir-1.0/Gtk4LayerShell-0.1.gir || die
			mkdir -p /usr/share/vala/vapi
			cp gtk4-layer-shell-0.vapi /usr/share/vala/vapi/
		fi
		
		einfo "Configuring GTK4 version"
		local gtk4_builddir="${WORKDIR}/gtk4-build"
		meson setup \
			--prefix="${EPREFIX}/usr" \
			--libdir="$(get_libdir)" \
			--buildtype=plain \
			--wrap-mode=nodownload \
			-Db_lto=false \
			-Db_pch=false \
			-Dwerror=false \
			${gtk4_builddir} \
			"${S}/lib/astal/gtk4" || die "GTK4 setup failed"
	fi
}

src_compile() {
	if use gtk3; then
		einfo "Building GTK3 version"
		meson compile -C "${WORKDIR}/gtk3-build" || die "GTK3 compile failed"
	fi
	
	if use gtk4; then
		einfo "Building GTK4 version"
		meson compile -C "${WORKDIR}/gtk4-build" || die "GTK4 compile failed"
	fi
}

src_install() {
	if use gtk3; then
		einfo "Installing GTK3 version"
		meson install -C "${WORKDIR}/gtk3-build" --destdir="${D}" || die "GTK3 install failed"
	fi
	
	if use gtk4; then
		einfo "Installing GTK4 version"
		meson install -C "${WORKDIR}/gtk4-build" --destdir="${D}" || die "GTK4 install failed"
	fi
}

pkg_postinst() {
	elog "Astal GTK widgets have been installed successfully."
	if use gtk3; then
		elog " - GTK3 support is enabled"
	fi
	if use gtk4; then
		elog " - GTK4 support is enabled"
	fi
}
