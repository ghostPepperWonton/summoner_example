defmodule Example.Api do
  @moduledoc """
  Handles the Tesla client creation and middleware for API requests
  """

  use Tesla

  plug Tesla.Middleware.JSON

  @spec get_summoner_by_name(name :: String.t()) :: Tesla.Env.result()
  def get_summoner_by_name(name) do
    client(%{region: "na1", token: "RGAPI-b05444e0-4eae-414e-9f68-bdd9d413a66a"})
    |> get("/summoner/v4/summoners/by-name/#{name}")
  end

  @spec get_matches_by_puuid(puuid :: String.t(), count :: integer()) ::
          Tesla.Env.result()
  def get_matches_by_puuid(puuid, count \\ 5) do
    client(%{
      region: "americas",
      token: "RGAPI-b05444e0-4eae-414e-9f68-bdd9d413a66a"
    })
    |> get(
      "/match/v5/matches/by-puuid/#{puuid}/ids?count=#{Integer.to_string(count)}"
    )
  end

  @spec get_match_details(match_id :: String.t()) :: Tesla.Env.result()
  def get_match_details(match_id) do
    client(%{
      region: "americas",
      token: "RGAPI-b05444e0-4eae-414e-9f68-bdd9d413a66a"
    })
    |> get("/match/v5/matches/#{match_id}")
  end

  defp client(%{region: region, token: token}) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://#{region}.api.riotgames.com/lol"},
      {Tesla.Middleware.Headers, [{"X-Riot-Token", token}]}
    ])
  end
end
