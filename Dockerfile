# CodeClimate specification: https://github.com/codeclimate/spec/blob/master/SPEC.md
#
# Build and run via:
#   docker build -t codeclimate/codeclimate-reek . && docker run codeclimate/codeclimate-reek

FROM ruby:2.3.3-alpine

MAINTAINER The Reek core team

ENV code_dir /code
ENV app_dir /usr/src/app
ENV user app

RUN apk --update add git
ADD . ${app_dir}

RUN adduser -u 9000 -D ${user}
RUN chown -R ${user}:${user} ${app_dir}
USER ${user}

WORKDIR ${app_dir}

RUN gem install rake
RUN bundle install --without debugging development

VOLUME ${code_dir}
WORKDIR ${code_dir}

CMD [ "/usr/src/app/bin/code_climate_reek" ]
