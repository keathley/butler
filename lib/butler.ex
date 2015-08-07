defmodule Butler do
  @slack_token Application.get_env(:slack, :api_key)
  @user_agent [ {"User-agent", "Butler the slack bot"} ]

  def main do
    start_url
    |> HTTPoison.get(@user_agent)
    |> handle_response
    |> extract_url
    |> connect_to_socket
    |> read_from_socket
  end

  def start_url do
    "https://slack.com/api/rtm.start?token=#{@slack_token}"
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect reason
    System.halt(2)
  end

  def extract_url(body) do
    %{"url" => url } = Poison.Parser.parse! body
    url
  end

  defp connect_to_socket(url) do
    IO.puts "Connecting to #{url}"
    Socket.connect!(url)
  end

  defp read_from_socket(socket) do
    case Socket.Web.recv!(socket) do
      { :text, resp } ->
        IO.puts resp
        resp |> Poison.Parser.parse! |> handle_slack_event(socket)
      { :ping, _} ->
        IO.puts "Ping"
      { _, resp } ->
        IO.puts "Unknown message: #{resp}"
      _ ->
        IO.puts "We're screwed"
    end

    read_from_socket(socket)
  end

  defp handle_slack_event(%{"type" => "message", "text" => text, "channel" => channel}, socket) do
    IO.puts "Message in #{channel}: #{text}"
    socket |> Socket.Web.send! { :text, ~s({"type": "message", "channel": "#{channel}", "text": "#{text} to you to"}) }
  end

  defp handle_slack_event(_, msg), do: msg
end
