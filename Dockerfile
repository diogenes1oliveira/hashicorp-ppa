FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y \
      gnupg=2.2.4-1ubuntu1.2 \
      dput=1.0.1ubuntu1 \
      dh-make=2.201701 \
      devscripts=2.17.12ubuntu1.1 \
      lintian=2.5.81ubuntu1 \
      software-properties-common=0.96.24.32.12

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/bin/bash" ]
