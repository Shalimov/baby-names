FROM ubuntu:18.04

ENV LANG=en_US.UTF-8 \
  HOME=/opt/build \
  TERM=xterm

WORKDIR /opt/build

RUN apt-get update -y && \
  apt-get install -y git wget vim locales gnupg gnupg1 gnupg && \
  locale-gen en_US.UTF-8

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
  dpkg --install erlang-solutions_1.0_all.deb && \
  rm erlang-solutions_1.0_all.deb

RUN apt-get update -y && \
  apt-get install esl-erlang -y && \
  apt-get install elixir -y

CMD ["/bin/bash"]
