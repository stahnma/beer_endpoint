%define debug_package %{nil}
%global _default_patch_fuzz 0
AutoProv: 0
AutoReq: 1

%global gem0 nokogiri
%global gem0version 1.5.10

Name:		  beer_endpoint
Version:  ==VERSION==
Release:	1%{?dist}
Summary:	weeee

Group:	Libraries/Beer
License:	MIT
URL:	http://github.com
Source0:	ruby-2.0.0-p247.tar.gz
Source1:  %{gem0}-%{gem0version}.gem
Source2:  %{name}-%{version}.tar.gz
Patch0:   ruby-2.0.0-p195-Fix-build-against-OpenSSL-with-enabled-ECC-curves.patch


# Needed for nokogiri
BuildRequires: libxml2-devel
BuildRequires: libxslt-devel

# Normal Ruby Stuff
BuildRequires: autoconf
BuildRequires: gdbm-devel
BuildRequires: ncurses-devel
BuildRequires: db4-devel
BuildRequires: libffi-devel
BuildRequires: openssl-devel
BuildRequires: libyaml-devel
BuildRequires: readline-devel

# Needed to pass test_set_program_name(TestRubyOptions)
BuildRequires: procps

# Requires for biulding of new gems and such
Requires: make
Requires: gcc
Requires: gcc-c++


%description
A jumbo package for the Puppet Labs beer endpoint.


%prep
%setup -q -n ruby-2.0.0-p247
%patch0 -p1

# Add nokogiri into the default gem set
tar xf %{SOURCE1}
tar zxf data.tar.gz
echo "%{gem0} lib/%{gem0}-%{gem0version} lib/%{gem0}/version.rb" >> defs/default_gems


tar xf %{SOURCE2}




%build
autoconf
./configure \
        --prefix=/opt/%{name} \
        --libdir=/opt/%{name}/lib \
        --disable-rpath \
        --enable-shared=no \
        --enable-static \
        --without-X11 \
        --disable-versioned-paths \
        --without-tcl \
        --without-tk \
        --without-win32ole \
        --without-fiddle

make %{?_smp_mflags} COPY="cp -p" Q=


%install
rm -rf $RPM_BUILD_ROOT

make install DESTDIR=%{buildroot}


# Setup environment to install gems
pushd $RPM_BUILD_ROOT/opt/%{name}
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./lib:$RPM_BUILD_ROOT/opt/%{name}/lib
export RUBYLIB=$RPM_BUILD_ROOT/opt/%{name}/lib:`pwd`/lib/ruby/2.0.0:`pwd`/lib/ruby/2.0.0/x86_64-linux/:./lib/ruby/2.0.0/gems:$RPM_BUILD_ROOT/opt/%{name}/lib/ruby/2.0.0/:$RPM_BUILD_ROOT/lib/ruby/2.0.0/x86_64-linux/
export GEM_DIR=$RPM_BUILD_ROOT/`./bin/ruby -e "puts Gem::dir"`

# Here we can install any non-compiled gem and have it be part of the rpm
./bin/ruby ./bin/gem install --no-rdoc --no-ri bundler
./bin/ruby ./bin/gem install --no-rdoc --no-ri awesome_print
./bin/ruby ./bin/gem install --no-rdoc --no-ri rack
./bin/ruby ./bin/gem install --no-rdoc --no-ri sinatra
./bin/ruby ./bin/gem install --no-rdoc --no-ri google_drive
popd

# Setup the actual application
mkdir -p $RPM_BUILD_ROOT/opt/%{name}/app/views
cp -pr %{name}-%{version}/app.rb $RPM_BUILD_ROOT/opt/%{name}/app
cp -pr %{name}-%{version}/views $RPM_BUILD_ROOT/opt/%{name}/app
cp -pr %{name}-%{version}/public $RPM_BUILD_ROOT/opt/%{name}/public
mkdir -p $RPM_BUILD_ROOT%{_initdir}
cp -pr %{name}.init $RPM_BUILD_ROOT%{_initdir}


# Fix shebang line of scripts
find $RPM_BUILD_ROOT -type f | xargs -n4 sed -i -e '1s,^#!.*ruby$,#!/opt/%{name}/bin/ruby,'



%post
echo "Installing compiled gems for application..."
/opt/%{name}/bin/gem list thin | grep thin &> /dev/null || /opt/%{name}/bin/gem install --no-rdoc --no-ri thin || true


%files
%doc %{name}-%{version}/LICENSE %{name}-%{version}/README.md
/opt/%{name}
%{_sysconfdir}/init.d/%{name}


%changelog
* Mon May 05 2014 Michael Stahnke <stahnma@puppetlabs.com> - 0.0.2-1
- Add an init script

* Sun Nov 17 2013 Michael Stahnke <stahnma@puppetlabs.com> - 0.0.1-1
- Initial Build
