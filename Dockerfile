FROM ruby:3.1.3-slim-bullseye

RUN apt-get update && \
  apt-get install -y freetds-dev \
  freetds-common \
  freetds-bin \
  build-essential \
  default-libmysqlclient-dev \
  default-libmysqlclient-dev \
  nodejs \
  npm

RUN gem install bundler -v 2.4.14

WORKDIR /app

COPY . /app

COPY Gemfile Gemfile.lock /app/

RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
