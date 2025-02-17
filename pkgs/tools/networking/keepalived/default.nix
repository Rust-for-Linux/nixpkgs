{ lib, stdenv, fetchFromGitHub, nixosTests
, file, libmnl, libnftnl, libnl
, net-snmp, openssl, pkg-config
, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "keepalived";
  version = "2.2.4";

  src = fetchFromGitHub {
    owner = "acassen";
    repo = "keepalived";
    rev = "v${version}";
    sha256 = "sha256-WXKu+cabMmXNHiLwXrQqS8GQHIWYkee7vPddyGURWic=";
  };

  buildInputs = [
    file
    libmnl
    libnftnl
    libnl
    net-snmp
    openssl
  ];

  enableParallelBuilding = true;

  passthru.tests.keepalived = nixosTests.keepalived;

  nativeBuildInputs = [ pkg-config autoreconfHook ];

  configureFlags = [
    "--enable-sha1"
    "--enable-snmp"
 ];

  meta = with lib; {
    homepage = "https://keepalived.org";
    description = "Routing software written in C";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
