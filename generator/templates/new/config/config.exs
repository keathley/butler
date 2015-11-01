use Mix.Config

config :butler,
  name: System.get_env("BUTLER_NAME") || "<%= app_name %>",
  adapter: Butler.Adapters.Console,
  plugins: [
    {Butler.Plugins.Help, []},
    {<%= mod_name %>.Example, []}
  ]

import_config "#{Mix.env}.exs"
