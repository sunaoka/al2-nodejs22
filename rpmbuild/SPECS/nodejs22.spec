Name:           nodejs
Version:        22.22.2
Release:        1%{?dist}
Summary:        JavaScript runtime built on Chrome's V8 engine

License:        MIT
URL:            https://nodejs.org/
Source0:        https://nodejs.org/dist/v%{version}/node-v%{version}.tar.xz

ExclusiveArch:  x86_64 aarch64

BuildRequires:  gcc10
BuildRequires:  gcc10-c++
BuildRequires:  make
BuildRequires:  python38
BuildRequires:  openssl-devel
BuildRequires:  xz

Requires:       openssl-libs

%global _lto_cflags %{nil}

%global __python %{python38}

%description
Node.js JavaScript runtime.

%prep
%autosetup -n node-v%{version}

%build
export CC=gcc10-gcc
export CXX=gcc10-g++

./configure \
    --prefix=%{_prefix}

%make_build

%install
%make_install

ln -srf \
    %{buildroot}%{_prefix}/lib/node_modules/npm/bin/npm-cli.js \
    %{buildroot}%{_bindir}/npm

ln -srf \
    %{buildroot}%{_prefix}/lib/node_modules/npm/bin/npx-cli.js \
    %{buildroot}%{_bindir}/npx

%check
export PATH=%{buildroot}%{_bindir}:$PATH

%{buildroot}%{_bindir}/node --version
%{buildroot}%{_bindir}/npm --version

%files
%license LICENSE
%doc README.md

%{_bindir}/node
%{_bindir}/npm
%{_bindir}/npx
%{_bindir}/corepack

%{_includedir}/node/

%{_prefix}/lib/node_modules/

%{_mandir}/man1/node.1*

%doc %{_datadir}/doc/node/

%changelog
* Tue May 12 2026 SUNAOKA Norifumi <sunaoka@pocari.org> - 22.22.2-1.amzn2
- Initial build for Amazon Linux 2
