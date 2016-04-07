FROM centos:latest
MAINTAINER stahnma@fedoraproject.org

# Setup EPEL
RUN yum -y install epel-release
# Now setup the application
# We need 0.3.6 of google drive because after that, you need oauth2, which
# means you need to enable the developer console per account inside each google
# account, and then setup a project etc. With the old password based way,
# anybody that access to the correct spreadsheet can run/use the application.
# It's just easier.
RUN yum clean all
RUN yum -y install ruby rubygems ruby-devel rubygem-nokogiri rubygem-bundler rubygem-json gcc make gcc-c++
# There are no rpms for sinatra or thin yet in EL/EPEL7
RUN gem install --no-rdoc --no-ri sinatra thin shotgun
RUN ln -s /usr/local/share/gems/gems/shotgun-0.9.1/bin/shotgun /usr/bin/shotgun
RUN yum -y upgrade
EXPOSE 8334
# The application will run out of /beer_endpoint as the user beer_endpoint
RUN useradd beer_endpoint
RUN mkdir -p /beer_endpoint
COPY views /beer_endpoint/views
COPY public /beer_endpoint/public
ADD  app.rb /beer_endpoint/app.rb
RUN chown -R beer_endpoint:beer_endpoint /beer_endpoint
CMD ruby /beer_endpoint/app.rb
