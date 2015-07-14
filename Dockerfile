FROM heroku/cedar:14

RUN useradd -d /app -m app
USER app
RUN mkdir -p /app/src
WORKDIR /app/src

ENV HOME /app
ENV RUBY_ENGINE 2.2.1
ENV BUNDLER_VERSION 1.7.12
ENV NODE_ENGINE 0.10.38
ENV PORT 3000

RUN mkdir -p /app/heroku/ruby
RUN curl -s https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/cedar-14/ruby-$RUBY_ENGINE.tgz | tar xz -C /app/heroku/ruby
ENV PATH /app/heroku/ruby/bin:$PATH

RUN mkdir -p /app/heroku/bundler
RUN mkdir -p /app/src/vendor/bundle
RUN curl -s https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/bundler-$BUNDLER_VERSION.tgz | tar xz -C /app/heroku/bundler
ENV PATH /app/heroku/bundler/bin:$PATH
ENV GEM_PATH=/app/heroku/bundler:$GEM_PATH
ENV GEM_HOME=/app/src/vendor/bundle

RUN mkdir -p /app/heroku/node
RUN curl -s https://s3pository.heroku.com/node/v$NODE_ENGINE/node-v$NODE_ENGINE-linux-x64.tar.gz | tar --strip-components=1 -xz -C /app/heroku/node
ENV PATH /app/heroku/node/bin:$PATH
WORKDIR /app/src

COPY Gemfile /app/src/
COPY Gemfile.lock /app/src/

USER root
RUN chown app /app/src/Gemfile* # ensure user can modify the Gemfile.lock
USER app

RUN bundle install # TODO: desirable if --path parameter were passed

COPY . /app/src

USER root
RUN chown -R app /app
USER app

RUN mkdir -p /app/.profile.d
RUN echo "export PATH=\"/app/heroku/ruby/bin:/app/heroku/bundler/bin:/app/heroku/node/bin:\$PATH\"" > /app/.profile.d/ruby.sh
RUN echo "export GEM_PATH=\"/app/heroku/bundler:/app/heroku/src/vendor/bundle:\$GEM_PATH\"" >> /app/.profile.d/ruby.sh
RUN echo "export GEM_HOME=\"/app/src/vendor/bundle\"" >> /app/.profile.d/ruby.sh

RUN echo "cd /app/src" >> /app/.profile.d/ruby.sh

EXPOSE 3000
