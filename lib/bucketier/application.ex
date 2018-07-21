defmodule Bucketier.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Bucketier.Registry},
      {DynamicSupervisor, name: Bucketier.BucketSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: Bucketier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
