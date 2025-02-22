{ lib
, buildPythonPackage
, cmake
, fetchFromGitHub
, gettext
, libcomps
, libdnf
, python
, rpm
, sphinx
}:

buildPythonPackage rec {
  pname = "dnf4";
  version = "4.18.2";
  format = "other";

  outputs = [ "out" "man" ];

  src = fetchFromGitHub {
    owner = "rpm-software-management";
    repo = "dnf";
    rev = version;
    hash = "sha256-WOLVKsrHp0V0wMXXRf1hrxsxuVv2bFOKIw8Aitz0cac=";
  };

  patches = [
    ./fix-python-install-dir.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "@PYTHON_INSTALL_DIR@" "$out/${python.sitePackages}" \
      --replace "SYSCONFDIR /etc" "SYSCONFDIR $out/etc" \
      --replace "SYSTEMD_DIR /usr/lib/systemd/system" "SYSTEMD_DIR $out/lib/systemd/system"
    substituteInPlace etc/tmpfiles.d/CMakeLists.txt \
      --replace "DESTINATION /usr/lib/tmpfiles.d" "DESTINATION $out/usr/lib/tmpfiles.d"
    substituteInPlace dnf/const.py.in \
      --replace "/etc" "$out/etc"
    substituteInPlace doc/CMakeLists.txt \
      --replace 'SPHINX_BUILD_NAME "sphinx-build-3"' 'SPHINX_BUILD_NAME "${sphinx}/bin/sphinx-build"'
  '';

  nativeBuildInputs = [
    cmake
    gettext
    sphinx
  ];

  propagatedBuildInputs = [
    libcomps
    libdnf
    rpm
  ];

  cmakeFlags = [
    "-DPYTHON_DESIRED=${lib.head (lib.splitString ["."] python.version)}"
  ];

  postBuild = ''
    make doc-man
  '';

  postInstall = ''
    # See https://github.com/rpm-software-management/dnf/blob/41a287e2bd60b4d1100c329a274776ff32ba8740/dnf.spec#L218-L220
    ln -s dnf-3 $out/bin/dnf
    ln -s dnf-3 $out/bin/dnf4
    mv $out/bin/dnf-automatic-3 $out/bin/dnf-automatic
    # See https://github.com/rpm-software-management/dnf/blob/41a287e2bd60b4d1100c329a274776ff32ba8740/dnf.spec#L231-L232
    ln -s $out/etc/dnf/dnf.conf $out/etc/yum.conf
    ln -s dnf-3 $out/bin/yum
  '';

  meta = with lib; {
    description = "Package manager based on libdnf and libsolv. Replaces YUM";
    homepage = "https://github.com/rpm-software-management/dnf";
    changelog = "https://github.com/rpm-software-management/dnf/releases/tag/${version}";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ katexochen ];
    mainProgram = "dnf";
    platforms = platforms.unix;
  };
}
