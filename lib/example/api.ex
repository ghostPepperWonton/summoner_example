defmodule Example.Api do
  @moduledoc """
  Handles the Tesla client creation and middleware for API requests
  """

  use Tesla

  plug Tesla.Middleware.JSON

  @type region ::
          "br1"
          | "eun1"
          | "euw1"
          | "jp1"
          | "kr"
          | "la1"
          | "la2"
          | "na1"
          | "oc1"
          | "ph2"
          | "ru"
          | "sg2"
          | "th2"
          | "tr1"
          | "tw2"
          | "vn2"
  @type broad_region :: "americas" | "asia" | "europe" | "sea"

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

  @spec get_summoner_by_name(region :: region(), name :: String.t()) ::
          Tesla.Env.result()
  def get_summoner_by_name(region, name) do
    region
    |> client()
    |> get("/lol/summoner/v4/summoners/by-name/#{name}")
  end

  @spec get_summoner_by_puuid(region :: region(), puuid :: String.t()) ::
          Tesla.Env.result()
  def get_summoner_by_puuid(region, puuid) do
    region
    |> client()
    |> get("/lol/summoner/v4/summoners/by-puuid/#{puuid}")
  end

  @spec get_account_by_puuid(region :: region(), puuid :: String.t()) ::
          Tesla.Env.result()
  def get_account_by_puuid(region, puuid) do
    region
    |> broad_region_for_region()
    |> client()
    |> get("/riot/account/v1/accounts/by-puuid/#{puuid}")
  end

  @spec get_matches_by_puuid(
          region :: region(),
          puuid :: String.t(),
          count :: integer()
        ) ::
          Tesla.Env.result()
  def get_matches_by_puuid(region, puuid, count \\ 5) do
    region
    |> broad_region_for_region()
    |> client()
    |> get(
      "/lol/match/v5/matches/by-puuid/#{puuid}/ids?count=#{Integer.to_string(count)}"
    )
  end

  @spec get_match_details(region :: region(), match_id :: String.t()) ::
          Tesla.Env.result()
  def get_match_details(region, match_id) do
    region
    |> broad_region_for_region()
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

  defp broad_region_for_region(region) do
    Map.get(@broad_from_region, region, "americas")
  end
end
