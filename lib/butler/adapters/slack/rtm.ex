defmodule Butler.Adapters.Slack.Rtm do
  @slack_token Application.get_env(:butler, :slack_api_key)
  @user_agent [ {"User-agent", "Butler the robot"} ]
  @url "https://slack.com/api/rtm.start?token=#{@slack_token}"

  def start do
    HTTPoison.get(@url, @user_agent) |> handle_response
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    json = Poison.Parser.parse!(body)
    {:ok, json}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
