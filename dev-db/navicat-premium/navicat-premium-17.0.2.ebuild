# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Navicat Premium is a multi-connection database development tool"
HOMEPAGE="https://navicat.com/en/navicat-17-highlights"
SRC_URI="https://dn.navicat.com/download/navicat17-premium-en-x86_64.AppImage -> ${P}.AppImage"

LICENSE="NAVICAT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="wayland"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-arch/libarchive
	dev-libs/glib:2
	sys-fs/fuse:0
	wayland? (
		dev-qt/qtwayland:5
	)
"
DEPEND="${RDEPEND}"
BDEPEND="dev-util/patchelf"

S="${WORKDIR}"

QA_PREBUILT="opt/${PN}/*"

src_unpack() {
	cp "${DISTDIR}/${P}.AppImage" "${WORKDIR}/" || die
	chmod +x "${WORKDIR}/${P}.AppImage" || die
	"${WORKDIR}/${P}.AppImage" --appimage-extract || die
	mv squashfs-root "${WORKDIR}/${PN}" || die
}

src_prepare() {
	default
	
	# Fix desktop file
	sed -i \
		-e 's/Categories=Application;/Categories=Development;Database;/' \
		"${WORKDIR}/${PN}/usr/share/applications/navicat.desktop" || die
	
	# Create Wayland launcher script if needed
	if use wayland; then
		cat > "${WORKDIR}/navicat-wayland" <<-EOF
		#!/bin/sh
		export QT_QPA_PLATFORM=wayland
		export XDG_SESSION_TYPE=wayland
		exec /opt/${PN}/AppRun "\$@"
		EOF
	fi
}

src_install() {
	# Create installation directories
	local installdir="/opt/${PN}"
	dodir "${installdir}"

	# Install Navicat files
	insinto "${installdir}"
	doins -r "${WORKDIR}/${PN}"/{AppRun,manual.pdf,usr}

	# Fix permissions
	fperms 0755 "${installdir}/AppRun"
	
	# Install desktop file and icon
	domenu "${WORKDIR}/${PN}/usr/share/applications/navicat.desktop"
	newicon "${WORKDIR}/${PN}/usr/share/icons/hicolor/256x256/apps/navicat-icon.png" "${PN}.png"

	# Create symlink
	dosym "${installdir}/AppRun" "/usr/bin/${PN}"
	
	# Create Wayland launcher if needed
	if use wayland; then
		exeinto /usr/bin
		doexe "${WORKDIR}/navicat-wayland"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Navicat Premium has been installed to ${installdir}"
	elog "Please note that this is commercial software with a trial period."
	elog "You will need to purchase a license for continued use."
	
	if use wayland; then
		elog ""
		elog "Wayland support has been enabled."
		elog "To run Navicat with native Wayland support, use the command 'navicat-wayland'"
		elog "If you experience issues with Wayland, you can still run Navicat under XWayland"
		elog "by using the regular '${PN}' command."
	fi
} 