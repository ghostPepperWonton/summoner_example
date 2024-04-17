defmodule Example.Api do
  @moduledoc """
  Handles the Tesla client creation and middleware for API requests
  """

  use Tesla

  alias Example.Session

  plug Tesla.Middleware.JSON

  @broad_from_region %{
    "br1" => "americas",
    "eun1" => "europe",
    "euw1" => "europe",
    "jp1" => "asia",
    "kr" => "asia",
    "la1" => "americas",
    "la2" => "americas",
    "na1" => "americas",
    "oc1" => "sea",
    "ph2" => "sea",
    "ru" => "europe",
    "sg2" => "sea",
    "th2" => "sea",
    "tr1" => "europe",
    "tw2" => "sea",
    "vn2" => "sea"
  }

  @spec get_summoner_by_name(session :: Session.t(), name :: String.t()) ::
          Tesla.Env.result()
  def get_summoner_by_name(session, name) do
    session
    |> client()
    |> get("/lol/summoner/v4/summoners/by-name/#{name}")
  end

  @spec get_summoner_by_puuid(session :: Session.t(), puuid :: String.t()) ::
          Tesla.Env.result()
  def get_summoner_by_puuid(session, puuid) do
    session
    |> client()
    |> get("/lol/summoner/v4/summoners/by-puuid/#{puuid}")
  end

  @spec get_account_by_puuid(session :: Session.t(), puuid :: String.t()) ::
          Tesla.Env.result()
  def get_account_by_puuid(session, puuid) do
    session
    |> broad_region_for_region()
    |> client()
    |> get("/riot/account/v1/accounts/by-puuid/#{puuid}")
  end

  @spec get_matches_by_puuid(
          session :: Session.t(),
          puuid :: String.t(),
          count :: integer()
        ) ::
          Tesla.Env.result()
  def get_matches_by_puuid(session, puuid, count \\ 5) do
    session
    |> broad_region_for_region()
    |> client()
    |> get(
      "/lol/match/v5/matches/by-puuid/#{puuid}/ids?count=#{Integer.to_string(count)}"
    )
  end

  @spec get_match_details(session :: Session.t(), match_id :: String.t()) ::
          Tesla.Env.result()
  def get_match_details(session, match_id) do
    session
    |> broad_region_for_region()
    |> client()
    |> get("/lol/match/v5/matches/#{match_id}")
  end

  defp client(%Session{region: region, token: token}) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, "https://#{region}.api.riotgames.com"},
      {Tesla.Middleware.Headers, [{"X-Riot-Token", token}]}
    ])
  end

  defp broad_region_for_region(%Session{region: region} = session) do
    %Session{session | region: Map.get(@broad_from_region, region, "americas")}
  end
end
