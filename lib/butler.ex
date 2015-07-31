defmodule Butler do

  def main(args) do
    HTTPoison.start

    options = args |> parse_args
    token = options[:token]
    IO.puts "Connection to ChaDev Slack with Token: #{token}"
    start_url = "https://slack.com/api/rtm.start?token=#{token}"

    case HTTPoison.get(start_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> get_url |> connect_to_socket |> read_from_socket

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def parse_args([]) do
    IO.puts "Required a Slack Bot Token"
  end

  def parse_args(args) do
    { options, _, _} = OptionParser.parse(args,
      switches: [name: :string]
    )

    options
  end

  defp get_url body do
    %{"url" => url } = Poison.Parser.parse! body
    IO.puts "WebSocket URL: #{url}"
    url
  end

  defp connect_to_socket url do
    socket = Socket.Web.connect! url
  end

  defp read_from_socket socket do
    IO.puts(Socket.Web.recv!(socket))
  end
end
