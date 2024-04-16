import Config

config :example,
  environment: Mix.env(),
  ecto_repos: [Example.Repo]

config :example, Example.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRESQL_USERNAME"),
  password: System.get_env("POSTGRESQL_PASSWORD"),
  database: System.get_env("POSTGRESQL_DATABASE"),
  hostname: System.get_env("POSTGRESQL_HOSTNAME")

config :example, :token, System.get_env("TOKEN")
