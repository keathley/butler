defmodule Butler do
  HTTPoison.start

  # client_id = System.get_env BUTLER_KEY
  # team = "chadev"
  # state = "crunk"
  start_url = "https://slack.com/api/rtm.start?token="<>client_id

  case HTTPoison.get(start_url) do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
      Butler.get_url body
      # IO.puts body
    {:error, %HTTPoison.Error{reason: reason}} ->
      IO.inspect reason
  end

  #ip_pack = Poison.Parser.parse!()

  def get_url body do
    %{"url" => url } = Poison.Parser.parse! body
    IO.puts url
  end
end
