{ lib
, buildGoModule
, fetchFromGitHub
, testers
, trivy
}:

buildGoModule rec {
  pname = "trivy";
  version = "0.48.0";

  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-NINEitFZm1d0foG1P+evLiXXNVNwzK3PMCicksDaBFc=";
  };

  # Hash mismatch on across Linux and Darwin
  proxyVendor = true;

  vendorHash = "sha256-EYcOOQBwzXu87q0EfJr7TUypGJW3qtosP3ARLssPOS8=";

  subPackages = [ "cmd/trivy" ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/aquasecurity/trivy/pkg/version.ver=v${version}"
  ];

  # Tests require network access
  doCheck = false;

  doInstallCheck = true;

  passthru.tests.version = testers.testVersion {
    package = trivy;
    command = "trivy --version";
    version = "Version: v${version}";
  };

  meta = with lib; {
    homepage = "https://github.com/aquasecurity/trivy";
    changelog = "https://github.com/aquasecurity/trivy/releases/tag/v${version}";
    description = "A simple and comprehensive vulnerability scanner for containers, suitable for CI";
    longDescription = ''
      Trivy is a simple and comprehensive vulnerability scanner for containers
      and other artifacts. A software vulnerability is a glitch, flaw, or
      weakness present in the software or in an Operating System. Trivy detects
      vulnerabilities of OS packages (Alpine, RHEL, CentOS, etc.) and
      application dependencies (Bundler, Composer, npm, yarn, etc.).
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ fab jk ];
  };
}
