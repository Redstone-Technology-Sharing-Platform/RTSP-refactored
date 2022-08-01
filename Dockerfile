FROM elixir:1.13.4-alpine
COPY . /www/
WORKDIR /www/rtsp
RUN mix archive.install ./hex-1.0.1.ez --force;
RUN HEX_MIRROR=https://cdn.jsdelivr.net/hex mix deps.get ; mix compile
CMD [ "mix", "run", "--no-halt" ]
