defmodule Butler do

  def start_link do
    HTTPoison.start

    client_id = System.get_env "BUTLER_KEY"
    start_url = "https://slack.com/api/rtm.start?token="<>client_id

    case HTTPoison.get(start_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> get_url
        # |> connect_to_socket
        # |> read_from_socket
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  defp get_url body do
    %{"url" => url } = Poison.Parser.parse! body
    IO.puts url
    url
  end

  defp connect_to_socket url do
    socket = Socket.Web.connect! url
  end

  defp read_from_socket socket do
    IO.puts(Socket.Web.recv!(socket))
  end
end
