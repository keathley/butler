defmodule Butler do

  client_id = "xoxb-8072126112-SO33tzVKXOjuNnd4BLsb6d1r"
  team = "chadev"
  state = "crunk"
  url = "htpps://slack.com/oauth/authorize?client_id"<>client_id<>"&team="<>team<>"&state="<>state
  IO.puts url
  HTTPoison.start
  response = HTTPoison.get! "http://ip.jsontest.com/"
  
  #ip_pack = Poison.Parser.parse!()
end
