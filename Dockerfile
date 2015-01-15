FROM centos:latest
MAINTAINER stahnma@fedoraproject.org

# Setup EPEL
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
# Now setup the application
# We need 0.3.6 of google drive because after that, you need oauth2, which
# means you need to enable the developer console per account inside each google
# account, and then setup a project etc. With the old password based way,
# anybody that access to the correct spreadsheet can run/use the application.
# It's just easier.
RUN yum -y install ruby rubygems ruby-devel rubygem-nokogiri rubygem-bundler rubygem-json gcc make gcc-c++
# There are no rpms for google_drive, sinatra or thin yet in EL/EPEL7
RUN gem install --no-rdoc --no-ri -v 0.3.6 google_drive
RUN gem install --no-rdoc --no-ri sinatra thin

# The application will run out of /beer_endpoint as the user beer_endpoint
RUN mkdir -p /beer_endpoint
ADD  app.rb /beer_endpoint/app.rb
COPY views /beer_endpoint/views
COPY public /beer_endpoint/public
RUN useradd beer_endpoint
RUN chown -R beer_endpoint:beer_endpoint /beer_endpoint
EXPOSE 8334
ENTRYPOINT ruby /beer_endpoint/app.rb
