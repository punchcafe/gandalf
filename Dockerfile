FROM elixir:1.16.0

COPY lib lib
COPY priv priv
COPY config config
COPY assets assets

COPY mix.exs mix.exs
COPY mix.lock mix.lock

RUN mix deps.get
RUN MIX_ENV=prod mix release

FROM elixir:1.16.0

EXPOSE 4000/tcp

COPY --from=0 /_build/prod/rel/gandalf /app
CMD /app/bin/gandalf start