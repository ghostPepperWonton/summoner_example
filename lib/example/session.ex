defmodule Example.Session do
  @moduledoc """
  Holds onto the necessary info for making API requests
  """

  use Ecto.Schema

  alias __MODULE__

  @type t :: %__MODULE__{
          region: String.t(),
          token: String.t()
        }

  schema "session" do
    field :region, :string
    field :token, :string
  end

  @spec new(region :: String.t(), token :: String.t() | nil) :: t()
  def new(region, token \\ nil) do
    %Session{
      region: region,
      token: token || Application.get_env(:example, :token)
    }
  end
end
