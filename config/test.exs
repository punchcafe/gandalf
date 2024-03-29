import Config

config :gandalf, :resource_directory_fetcher, fn -> "./test/support/test_resources" end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gandalf, GandalfWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Soz/bit3dXyCzxwCZIokUuGKqtK85p8JBKDqmvSw5yMS1bjeR6oimEZJ+u9rZXEg",
  server: false

# In test we don't send emails.
config :gandalf, Gandalf.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :gandalf, Gandalf.Session.Config,
  questions_per_topic: 3,
  failure_threshold: 0.6,
  max_topic_suggestions: 1
