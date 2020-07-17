defmodule AG.ComplimentRetrieveBehaviour do
  @callback show(String.t()) :: :ok | {:error, AG.ComplimentRetrieve.Error.t()}
end
