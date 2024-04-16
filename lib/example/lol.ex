defmodule Example.Lol do
  @moduledoc """
  Makes the logical connections between the data gathered from the API
  """

  alias Example.Api
  alias Example.Repo
  alias Example.Summoner

  @spec summoner_name(puuid :: String.t()) :: {:ok | :error, String.t()}
  def summoner_name(puuid) do
    with nil <- Summoner.get_by_puuid(puuid),
         {:ok,
          %Tesla.Env{
            status: 200,
            body: %{"id" => riot_id, "accountId" => account_id}
          }} <-
           Api.get_summoner_by_puuid(puuid),
         {:ok, %Tesla.Env{status: 200, body: %{"gameName" => name}}} <-
           Api.get_account_by_puuid(puuid) do
      %{riot_id: riot_id, account_id: account_id, puuid: puuid, name: name}
      |> Summoner.new()
      |> Repo.insert()

      {:ok, name}
    else
      %Summoner{name: name} ->
        {:ok, name}

      _ ->
        {:error, "No name found for '#{puuid}'"}
    end
  end

  @spec summoner_puuid(name :: String.t()) :: {:ok | :error, String.t()}
  def summoner_puuid(name) do
    with nil <- Summoner.get_by_name(name),
         {:ok,
          %Tesla.Env{
            status: 200,
            body: %{
              "id" => riot_id,
              "accountId" => account_id,
              "puuid" => puuid
            }
          }} <- Api.get_summoner_by_name(name) do
      %{riot_id: riot_id, account_id: account_id, puuid: puuid, name: name}
      |> Summoner.new()
      |> Repo.insert()

      {:ok, puuid}
    else
      %Summoner{puuid: puuid} ->
        {:ok, puuid}

      _ ->
        {:error, "No puuid found for '#{name}'"}
    end
  end

  @spec recent_matches(name :: String.t(), count :: integer()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def recent_matches(name, count \\ 5) do
    with {:ok, puuid} <- summoner_puuid(name),
         {:ok, %Tesla.Env{status: 200, body: matches}} when is_list(matches) <-
           Api.get_matches_by_puuid(puuid, count) do
      {:ok, matches}
    else
      {:ok, %Tesla.Env{status: status}} ->
        {:error, "Request failed with status #{status}"}

      {:error, %Tesla.Env{}} ->
        {:error, "Request failed, please try again"}

      {:error, message} ->
        {:error, message}
    end
  end

  @spec match_participants(match_id :: String.t()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def match_participants(match_id) do
    case Api.get_match_details(match_id) do
      {:ok,
       %Tesla.Env{
         status: 200,
         body: %{"metadata" => %{"participants" => participant_puuids}}
       }}
      when is_list(participant_puuids) ->
        participant_names =
          participant_puuids
          |> Enum.map(fn puuid ->
            case summoner_name(puuid) do
              {:ok, name} -> name
              _error -> nil
            end
          end)
          |> Enum.reject(&is_nil/1)

        {:ok, participant_names}

      _ ->
        {:error, "Unable to find participants for match '#{match_id}'"}
    end
  end

  @spec recent_summoner_participants(
          name :: String.t(),
          match_count :: integer()
        ) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def recent_summoner_participants(name, match_count \\ 5) do
    case recent_matches(name, match_count) do
      {:ok, match_ids} ->
        participants =
          match_ids
          |> Enum.reduce([], fn match_id, acc ->
            case match_participants(match_id) do
              {:ok, participants} -> Enum.concat(acc, participants)
              {:error, _message} -> acc
            end
          end)
          |> Enum.uniq()

        {:ok, participants}

      {:error, message} ->
        {:error, message}
    end
  end
end
