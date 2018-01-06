defmodule Fuelsystem.Adapters.LocalAdapter do
  @behaviour Fuelsystem.Adapter

  def read(filesystem, path) do
    with {:ok, path} = full_path(path, filesystem) do
      File.read(path)
    end
  end

  defp full_path(path, filesystem) do
    root =
      filesystem
      |> config()
      |> Keyword.get(:root)

    case root do
      nil ->
        with {:ok, root} <- File.cwd() do
          {:ok, Path.join([root, path])}
        end

      root ->
        {:ok, Path.join([root, path])}
    end
  end

  defp config(filesystem) do
    Application.get_env(filesystem.__app__, filesystem, [])
  end
end
