Name:		beer-endpoint
Version:	0.0.1
Release:	1%{?dist}
Summary:	A webservice for a kegerator

Group:		Applications/Internet
License:	ASL 2.0
URL:		https://github.com/stahnma/beer_endpoint
Source0:	beer_endpoint.tar.gz

BuildRequires:	ruby > 1.8
BuildRequires:	rubygems
BuildRequires:	rubygem-bundler rubygem-rake rubygem-json
BuildRequires:	libxml2-devel libxslt-devel



%description
Foo Bar


%prep
%setup -q


%build
%configure
make %{?_smp_mflags}


%install
make install DESTDIR=%{buildroot}


%files
%doc



%changelog

