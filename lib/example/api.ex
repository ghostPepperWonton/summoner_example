defmodule Example.Api do
  @moduledoc """
  Handles the Tesla client creation and middleware for API requests
  """

  use Tesla

  plug Tesla.Middleware.JSON

  @spec get_summoner_by_name(name :: String.t(), region :: String.t()) ::
          Tesla.Env.result()
  def get_summoner_by_name(name, region \\ "na1") do
    region
    |> client()
    |> get("/lol/summoner/v4/summoners/by-name/#{name}")
  end

  @spec get_summoner_by_puuid(puuid :: String.t(), region :: String.t()) ::
          Tesla.Env.result()
  def get_summoner_by_puuid(puuid, region \\ "na1") do
    region
    |> client()
    |> get("/lol/summoner/v4/summoners/by-puuid/#{puuid}")
  end

  @spec get_account_by_puuid(puuid :: String.t(), region :: String.t()) ::
          Tesla.Env.result()
  def get_account_by_puuid(puuid, region \\ "americas") do
    region
    |> client()
    |> get("/riot/account/v1/accounts/by-puuid/#{puuid}")
  end

  @spec get_matches_by_puuid(
          puuid :: String.t(),
          count :: integer(),
          region :: String.t()
        ) ::
          Tesla.Env.result()
  def get_matches_by_puuid(puuid, count \\ 5, region \\ "americas") do
    region
    |> client()
    |> get(
      "/lol/match/v5/matches/by-puuid/#{puuid}/ids?count=#{Integer.to_string(count)}"
    )
  end

  @spec get_match_details(match_id :: String.t(), region :: String.t()) ::
          Tesla.Env.result()
  def get_match_details(match_id, region \\ "americas") do
    region
    |> client()
    |> get("/lol/match/v5/matches/#{match_id}")
  end

  defp client(region) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://#{region}.api.riotgames.com"},
      {Tesla.Middleware.Headers, [{"X-Riot-Token", token()}]}
    ])
  end

  defp token do
    Application.get_env(:example, :token)
  end
end
