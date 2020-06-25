defmodule AG.Compliment do
  use Ecto.Schema

  import Ecto.Changeset

  @valid_types ~w(helpful sharing innovative)

  @timestamps_opts [type: :utc_datetime]
  schema "compliments" do
    field :recipient_id, :string
    field :sender_id, :string
    field :type, :string
    field :description, :string
    field :created_date, :date

    timestamps(updated_at: false)
  end

  @type t :: %__MODULE__{}

  def changeset(compliment \\ %__MODULE__{}, attrs) do
    compliment
    |> cast(attrs, [:type, :sender_id, :recipient_id, :description])
    |> validate_required([:type, :sender_id, :recipient_id])
    |> validate_inclusion(:type, @valid_types)
    |> put_change(:created_date, Date.utc_today())
    |> unique_constraint([:sender_id, :created_date])
  end
end
