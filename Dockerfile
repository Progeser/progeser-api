FROM ruby:3.3.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client graphviz
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
COPY . /myapp

# Start the main process.
ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
