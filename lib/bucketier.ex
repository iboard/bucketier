defmodule Bucketier do
  @moduledoc """
  Documentation for Bucketier.
  """

  @doc """
  Get a Bucket by name. If bucket doesn't exist, a new bucket gets started.

  ## Examples

      iex> Bucketier.bucket("my bucket")
      %Bucketier.Bucket{ name: "my bucket", data: %{} }

  """
  def bucket(name) do
    Bucketier.Bucket.bucket(name)
  end
end
