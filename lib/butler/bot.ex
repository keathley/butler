defmodule Butler.Bot do
  use GenServer

  def start_link(opts \\ []) do
    {:ok, json} = Butler.Rtm.start

    GenServer.start_link(__MODULE__, json, opts)
  end

  def init(json) do
    IO.puts "init"
    # IO.inspect json
    # |> connect_to_socket
    # |> read_from_socket
    slack = %{
      me: json.self,
      team: json.team,
      channels: json.channels,
      groups: json.groups,
      users: json.users
    }

    [user | rest ] = slack.users

    IO.inspect user 
    {:ok, slack}
  end

  def extract_url(body) do
    IO.puts body
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
