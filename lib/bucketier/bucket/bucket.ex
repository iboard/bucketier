defmodule Bucketier.Bucket do
  @moduledoc ~S"""
  The _Bucket_ is an `Agent` holding the state of a `Map` as its content.
  Buckets are started automatically if not found in the `Registry`.

  The `DynamicSupervisor` named `Bucketier.BucketSupervisor`, started 
  in `Bucketier.Application`, starts new Buckets and supervises them.
  """
  alias __MODULE__

  use Agent, restart: :transient


  @type t :: %__MODULE__{ name: String.t(), data: any }
  defstruct [:name, :data]


  @doc ~S"""
  `start_link` is called by the `Bucketier.BucketSupervisor` through

      DynamicSupervisor.start_child(Bucketier.BucketSupervisor, {Bucketier.Bucket, name})

  You don't have to call this `start_link` on your own. `Bucketier.Bucket.bucket/1` will
  initiate the start of the new Bucket as a child of the supervisor.
  """
  def start_link(name) do
    Agent.start_link( fn -> %Bucket{ name: name, data: %{} } end, name: via_tuple(name) ) 
  end

  @doc ~S"""
  Find a bucket with the given `pid` or `name` and return its state. 
  A new `name` will instantiate a new `Bucketier.Bucket` and returns an empty state.

  ### Examples:

      iex> Bucketier.Bucket.bucket(:shopping_list)
      %Bucketier.Bucket{ name: :shopping_list, data: %{} }

  If you pass a `pid` instead of `name` the function will return the
  state of this bucket. If a Bucket with this pid does not exists, the function
  will return {:error, :bucket_not_alive}

  ### Examples:

      iex> Bucketier.Bucket.bucket(:shopping_list)
      iex> [{pid,_}] = Registry.lookup(Bucketier.Registry, :shopping_list)
      iex> Bucketier.Bucket.bucket(pid)
      %Bucketier.Bucket{ name: :shopping_list, data: %{} }


      iex> Bucketier.Bucket.bucket(:shopping_list)
      iex> [{pid,_}] = Registry.lookup(Bucketier.Registry, :shopping_list)
      iex> Agent.stop(pid,:shutdown)
      iex> Bucketier.Bucket.bucket(pid)
      { :error, :bucket_not_alive }
  """
  @spec bucket( String.t | pid() ) :: Bucketier.Bucket.t()
  def bucket(pid_or_name) when is_pid(pid_or_name) do
    case Process.alive?(pid_or_name) do
      true -> Agent.get(pid_or_name, fn(state) -> state end)
      false -> {:error, :bucket_not_alive}
    end
  end
  def bucket(name) do
    lookup(name)
    |> Agent.get( fn(state) -> state end)
  end

  @doc ~S"""
  Put a new key/value-pair into a bucket-struct. 

  *Note*: This updates the struct im memory only. No Bucket on the server
  will actually be uptdated! If you want your changes to be persistent,
  please see: `commit/1`.

  ### Example:

      iex> %Bucketier.Bucket{ name: "B1", data: %{} }
      iex> |> Bucketier.Bucket.put( :some_key, "some value" )
      %Bucketier.Bucket{ name: "B1", data: %{ some_key: "some value" } }

  """
  def put( bucket, key, value ) do
    bucket
    |> Map.merge( %{ data: Map.merge(bucket.data, %{ key => value }) } )
  end

  @doc ~S"""
  Commit the state of the `bucket`, thus the next request to `bucket/1`
  will return this state.

  ### Example:

      iex> %Bucketier.Bucket{ name: "B1", data: %{} }
      iex> |> Bucketier.Bucket.put( :some_key, "some value" )
      iex> |> Bucketier.Bucket.commit
      iex> Bucketier.Bucket.bucket("B1")
      %Bucketier.Bucket{ name: "B1", data: %{ some_key: "some value" } }

  """
  def commit( bucket ) do
    pid = lookup(bucket.name)
    Agent.update( pid, fn(_b) -> bucket end)
  end

  @doc ~S"""
  Drops all buckets! This function is used mainly from tests but
  there maybe some use-cases where you want to get rid of all data.
  """
  def drop_all! do
    Supervisor.which_children(Bucketier.BucketSupervisor)
    |> Enum.each( fn {_,pid,_,_}  -> Agent.stop(pid) end)
  end


  ## Helpers
  
  defp start_agent(name) do
    {:ok, pid } = DynamicSupervisor.start_child(Bucketier.BucketSupervisor, {Bucketier.Bucket, name})
    pid
  end

  defp lookup(name) do
    case Registry.lookup( Bucketier.Registry, name ) do
      [] -> start_agent(name)
      [{pid,_}] -> pid
    end
  end

  defp via_tuple(name), do: {:via, Registry, {Bucketier.Registry, name}}
end
