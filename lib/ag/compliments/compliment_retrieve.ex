defmodule AG.ComplimentRetrieve do
  @behaviour AG.ComplimentRetrieveBehaviour

  defmodule Error do
    defexception [:message]

    @type t :: %__MODULE__{}

    @spec new(String.t()) :: t()
    def new(msg) do
      %__MODULE__{message: msg}
    end
  end

  alias AG.{Compliment, Repo}

  @user_storage Application.get_env(:ag, :user_storage)

  @doc """
  Creates a compliment.
  """
  @impl true
  def show(recipient_id) do
    with :ok <- inquire_compliments(recipient_id) do
      :ok
    else
      {:error, msg} ->
        {:error, Error.new(msg)}
    end
  end

  defp inquire_compliments(recipient_id) do
    %{recipient_id: recipient_id}
    |> Compliment.changeset()
    |> Repo.get()
    |> case do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        {:error, to_error_msg(changeset)}
    end
  end

  defp to_error_msg(%Ecto.Changeset{errors: [error | _]}) do
    case error do
      "recipient not found"
    end
  end
end
