defmodule Fuelsystem.Adapter do
  alias Fuelsystem.Config

  @typedoc """
  A module, which does implement the `Fuelsystem.Adapter` behaviour.
  """
  @type t :: module

  @doc """
  """
  @callback read(filesystem :: Fuelsystem.t(), path :: Fuelsystem.path()) ::
              {:ok, binary} | {:error, term}
end
