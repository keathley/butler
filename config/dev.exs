use Mix.Config

config :butler,
  adapter: Butler.Adapters.Console,
  plugins: [
    {ButlerCowsay, []}
  ]
