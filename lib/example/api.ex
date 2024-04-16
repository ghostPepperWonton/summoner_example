defmodule Example.Api do
  @moduledoc """
  Handles the Tesla client creation and middleware for API requests
  """

  use Tesla

  plug Tesla.Middleware.JSON

  @spec get_summoner_by_name(name :: String.t()) :: Tesla.Env.result()
  def get_summoner_by_name(name) do
    "na1"
    |> client()
    |> get("/summoner/v4/summoners/by-name/#{name}")
  end

  @spec get_matches_by_puuid(puuid :: String.t(), count :: integer()) ::
          Tesla.Env.result()
  def get_matches_by_puuid(puuid, count \\ 5) do
    "americas"
    |> client()
    |> get(
      "/match/v5/matches/by-puuid/#{puuid}/ids?count=#{Integer.to_string(count)}"
    )
  end

  @spec get_match_details(match_id :: String.t()) :: Tesla.Env.result()
  def get_match_details(match_id) do
    "americas"
    |> client()
    |> get("/match/v5/matches/#{match_id}")
  end

  defp client(region) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://#{region}.api.riotgames.com/lol"},
      {Tesla.Middleware.Headers, [{"X-Riot-Token", token()}]}
    ])
  end

  defp token do
    Application.get_env(:example, :token)
  end
end
