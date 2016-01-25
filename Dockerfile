# CodeClimate specification: https://github.com/codeclimate/spec/blob/master/SPEC.md
#
# Build and run via:
#   docker build -t codeclimate/codeclimate-reek . && docker run codeclimate/codeclimate-reek

FROM codeclimate/alpine-ruby:b38

MAINTAINER The Reek core team

ENV code_dir /code
ENV app_dir /usr/src/app
ENV user app

RUN apk --update add git

ADD . ${app_dir}

WORKDIR ${app_dir}

RUN bundle install --without debugging development
RUN adduser -u 9000 -D ${user}
RUN chown -R ${user}:${user} ${app_dir}

VOLUME ${code_dir}
WORKDIR ${code_dir}
USER ${user}

CMD [ "/usr/src/app/bin/code_climate_reek" ]
