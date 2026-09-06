{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  glib,
  libusb1,
  gusb,
  pixman,
  openssl,
  nss,
  nspr,
  gobject-introspection,
  libfprintSrc ? null,
}:
stdenv.mkDerivation rec {
  pname = "libfprint-goodix";
  version = "1.94.5-goodixtls";

  src =
    if libfprintSrc != null
    then libfprintSrc
    else
      fetchFromGitHub {
        owner = "jitendradara12";
        repo = "libfprint";
        rev = "2cdcd4e683b41a7265210269e817b1fc8b57f582";
        hash = "sha256-LBPKtl+ygaowr49vi6Cjn8bkEGY0lZTXQRLvfYHslzw=";
      };

  postPatch = ''
    sed -i "s/1.94.5/1.94.9/" meson.build
    sed -i "s/FP_DEVICE_RETRY_REMOVE_FINGER,/FP_DEVICE_RETRY_REMOVE_FINGER,\n  FP_DEVICE_RETRY_TOO_FAST,/" libfprint/fp-device.h
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    glib
    libusb1
    gusb
    pixman
    openssl
    nss
    nspr
  ];

  mesonFlags = [
    "-Ddrivers=goodixtls5e0a"
    "-Dgtk-examples=false"
    "-Ddoc=false"
    "-Dudev_rules=enabled"
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    "-Dudev_hwdb=disabled"
  ];

  meta = with lib; {
    description = "libfprint fork with support for Goodix 27c6:5e0a TLS fingerprint scanner";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
