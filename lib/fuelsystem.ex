defmodule Fuelsystem do
  @moduledoc """
  Fuelsystem is a filesystem abstraction library inspired by [flysystem](https://github.com/thephpleague/flysystem).
  """
  alias Fuelsystem.Config

  ##############################################################################
  # Types
  #

  @typedoc "A module implementing this behaviour"
  @type t :: module

  @typedoc "A representation of a file"
  @type file :: term

  @typedoc "A representation of a file with streamed content"
  @type streamed_file :: term

  @typedoc "A representation of a directory"
  @type dir :: term

  @typedoc "Absolute path within the filesystem"
  @type path :: binary

  @typedoc "File contents supplied to write operations"
  @type content :: binary

  @typedoc "Streamed file contents supplied to write operations"
  @type stream_content :: term

  @typedoc "Used to mark a file public"
  @type public :: :public

  @typedoc "Used to mark a file private"
  @type private :: :private

  @typedoc "Visibility options for files"
  @type visibility :: public | private

  ##############################################################################
  # Macros
  #
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts, mod: __MODULE__] do
      @behaviour Fuelsystem

      {otp_app, adapter} = mod.compile_config(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter

      def __adapter__ do
        @adapter
      end

      def __app__ do
        @otp_app
      end

      def read(path) do
        @adapter.read(__MODULE__, path)
      end
    end
  end

  @doc """
  Retrieves the compile time configuration.
  """
  def compile_config(repo, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config = Application.get_env(otp_app, repo, [])
    adapter = opts[:adapter] || config[:adapter]

    unless adapter do
      raise ArgumentError,
            "missing :adapter configuration in " <> "config #{inspect(otp_app)}, #{inspect(repo)}"
    end

    unless Code.ensure_loaded?(adapter) do
      raise ArgumentError,
            "adapter #{inspect(adapter)} was not compiled, " <>
              "ensure it is correct and it is included as a project dependency"
    end

    {otp_app, adapter}
  end

  ##############################################################################
  # Implementation
  #
  @optional_callbacks init: 1

  @doc false
  @callback __adapter__ :: Fuelsystem.Adapter.t()

  @doc false
  @callback __app__ :: atom

  @doc """
  Use this for runtime configuration before startup.
  """
  @callback init(config :: keyword) :: keyword

  ##############################################################################
  # Reads
  #

  @doc """
  Read a file.
  """
  @callback read(path :: path) :: {:ok, [file]} | {:error, term}

  # @doc """
  # Read a new file using streamed content.
  # """
  # @callback read_stream(path :: path) :: {:ok, [streamed_file]} | {:error, term}

  # @doc """
  # List contents of a directory.
  # """
  # @callback list_contents(path :: path, recursive :: boolean) :: {:ok, [path]} | {:error, term}

  # ##############################################################################
  # # Writes
  # #

  # @doc """
  # Write a new file.
  # """
  # @callback write(path :: path, content :: content, config :: Config.t()) ::
  #             {:ok, [file]} | {:error, term}

  # @doc """
  # Write a new file using streamed content.
  # """
  # @callback write_stream(path :: path, content :: stream_content, config :: Config.t()) ::
  #             {:ok, [file]} | {:error, term}

  # @doc """
  # Update a file.
  # """
  # @callback update(path :: path, content :: content, config :: Config.t()) ::
  #             {:ok, [file]} | {:error, term}

  # @doc """
  # Update a file using streamed content.
  # """
  # @callback update_stream(path :: path, content :: stream_content, config :: Config.t()) ::
  #             {:ok, [file]} | {:error, term}

  # @doc """
  # Rename a file.
  # """
  # @callback update(path :: path, new_path :: path) :: :ok | {:error, term}

  # @doc """
  # Copy a file.
  # """
  # @callback update(path :: path, new_path :: path) :: :ok | {:error, term}

  # @doc """
  # Copy a file.
  # """
  # @callback copy(path :: path, new_path :: path) :: :ok | {:error, term}

  # @doc """
  # Delete a file.
  # """
  # @callback delete(path :: path) :: :ok | {:error, term}

  # @doc """
  # Create a directory.
  # """
  # @callback create_dir(path :: path, config :: Config.t()) :: {:ok, [dir]} | {:error, term}

  # @doc """
  # Delete a directory.
  # """
  # @callback delete_dir(path :: path) :: :ok | {:error, term}

  # @doc """
  # Set the visibility for a file.
  # """
  # @callback set_visibility(path :: path, visibility :: visibility) ::
  #             {:ok, [file]} | {:error, term}
end
