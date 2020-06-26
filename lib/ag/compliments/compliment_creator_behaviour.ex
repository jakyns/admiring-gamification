defmodule AG.ComplimentCreatorBehaviour do
  @callback create(String.t(), String.t(), String.t()) :: :ok | {:error, AG.ComplimentCreator.Error.t()}
end
