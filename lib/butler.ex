defmodule Butler do

  client_id = ""
  team = "chadev"
  state = "crunk"
  url = "htpps://slack.com/oauth/authorize?client_id"<>client_id<>"&team="<>team<>"&state="<>state
  IO.puts url
  HTTPoison.start
  response = HTTPoison.get! "http://ip.jsontest.com/"
  
  #ip_pack = Poison.Parser.parse!()
end
