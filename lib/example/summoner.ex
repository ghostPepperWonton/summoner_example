defmodule Example.Summoner do
  @moduledoc """
  A locally-stored cache for summoners for shortcutting tracking once requested
  """

  use Ecto.Schema

  alias __MODULE__
  alias Example.Repo

  @type t :: %__MODULE__{
          riot_id: String.t(),
          account_id: String.t(),
          puuid: String.t(),
          name: String.t()
        }

  schema "summoner" do
    field :riot_id, :string
    field :account_id, :string
    field :puuid, :string
    field :name, :string

    timestamps()
  end

  @spec new(%{
          riot_id: String.t(),
          account_id: String.t(),
          puuid: String.t(),
          name: String.t()
        }) :: t()
  def new(%{riot_id: riot_id, account_id: account_id, puuid: puuid, name: name}) do
    %Summoner{
      riot_id: riot_id,
      account_id: account_id,
      puuid: puuid,
      name: name
    }
  end

  @spec get_by_name(name :: String.t()) :: t() | nil
  def get_by_name(name) do
    Repo.get_by(Summoner, name: name)
  end

  @spec get_by_puuid(puuid :: String.t()) :: t() | nil
  def get_by_puuid(puuid) do
    Repo.get_by(Summoner, puuid: puuid)
  end
end
