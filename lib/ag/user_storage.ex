defmodule AG.UserStorage do
  use GenServer

  alias AG.SlackAPI.User

  require Logger

  @table_name :user_storage
  @recovery_duration :timer.seconds(10)
  @default_interval :timer.minutes(10)

  def start_link(opts \\ []) do
    slack_api = Keyword.fetch!(opts, :slack_api)
    interval = Keyword.get(opts, :interval, @default_interval)
    GenServer.start_link(__MODULE__, {slack_api, interval})
  end

  @spec get_user_by_name(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user_by_name(name) do
    case :ets.lookup(@table_name, name) do
      [{^name, user}] -> {:ok, user}
      _ -> {:error, :not_found}
    end
  end

  @impl true
  def init({slack_api, interval}) do
    :ets.new(@table_name, [:named_table, :set, :protected, read_concurrency: true])
    schedule_task(0)
    {:ok, %{slack_api: slack_api, interval: interval}}
  end

  @impl true
  def handle_info(:insert_users, %{slack_api: slack_api, interval: interval} = state) do
    Logger.info("Fetching & inserting users ...")

    case slack_api.list_active_users() do
      {:ok, users} ->
        table_objects = Enum.map(users, fn user -> {user.name, user} end)
        true = :ets.insert(@table_name, table_objects)
        schedule_task(interval)
        {:noreply, state}

      :error ->
        schedule_task(@recovery_duration)
        {:noreply, state}
    end
  end

  defp schedule_task(interval) do
    Process.send_after(self(), :insert_users, interval)
  end
end
