defmodule Ridex.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :phone, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:type, :phone])
    |> validate_required([:type, :phone])
  end
end
