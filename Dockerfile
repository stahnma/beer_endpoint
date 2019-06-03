FROM ruby:latest
MAINTAINER stahnma@fedoraproject.org


#RUN yum -y install ruby rubygems ruby-devel rubygem-nokogiri rubygem-bundler rubygem-json gcc make gcc-c++
RUN gem install  --no-doc sinatra thin shotgun nokogiri json bundler
EXPOSE 8334
## The application will run out of /beer_endpoint as the user beer_endpoint
RUN useradd beer_endpoint
RUN mkdir -p /beer_endpoint
COPY views /beer_endpoint/views
COPY public /beer_endpoint/public
ADD  app.rb /beer_endpoint/app.rb
#RUN chown -R beer_endpoint:beer_endpoint /beer_endpoint
CMD ruby /beer_endpoint/app.rb
