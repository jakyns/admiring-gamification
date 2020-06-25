defmodule AG.ComplimentCreator do
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

  @spec create(String.t(), String.t(), String.t()) :: :ok | {:error, Error.t()}
  def create(sender_id, recipient_name, type) do
    with {:ok, recipient_id} <- get_recipient_id(recipient_name),
         :ok <- check_recipient_and_sender(recipient_id, sender_id),
         :ok <- create_compliment(sender_id, recipient_id, type) do
      :ok
    else
      {:error, msg} ->
        {:error, Error.new(msg)}
    end
  end

  defp get_recipient_id(name) do
    case @user_storage.get_user_by_name(name) do
      {:ok, user} ->
        {:ok, user.id}

      {:error, :not_found} ->
        {:error, "user #{name} not found"}
    end
  end

  defp check_recipient_and_sender(recipient_id, sender_id) do
    if recipient_id == sender_id do
      {:error, "recipient and sender cannot be the same"}
    else
      :ok
    end
  end

  defp create_compliment(sender_id, recipient_id, type) do
    %{sender_id: sender_id, recipient_id: recipient_id, type: type}
    |> Compliment.changeset()
    |> Repo.insert()
    |> case do
      {:ok, _} ->
        :ok

      {:error, changeset} ->
        {:error, to_error_msg(changeset)}
    end
  end

  defp to_error_msg(%Ecto.Changeset{errors: [error | _]}) do
    case error do
      {:sender_id, {"has already been taken", _}} ->
        "compliment can be created once per day"

      {attr, _} ->
        "#{attr} is invalid"
    end
  end
end
