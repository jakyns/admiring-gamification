defmodule AG.SlackAPI.User do
  defstruct [:id, :name, :real_name]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          real_name: String.t()
        }
end
