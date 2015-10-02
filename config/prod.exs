use Mix.Config

config :butler,
  adapter: Butler.Adapters.Slack,
  slack_api_key: System.get_env("BUTLER_SLACK_API_KEY")

