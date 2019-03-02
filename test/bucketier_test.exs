defmodule BucketierTest do
  use ExUnit.Case, async: true
  doctest Bucketier.Bucket
  alias Bucketier.{Bucket}

  setup _ do
    b = Bucket.drop_all!()
    :timer.sleep(10)
    {:ok, %{ bucket: b}}
  end

  test "get a bucket by name" do
    bucket = Bucket.bucket("shopping list")
    assert %Bucket{name: "shopping list", data: %{}} == bucket
  end

  test "put something in a bucket" do
    bucket =
      Bucket.bucket("shopping list 1")
      |> Bucket.put(1, "Milk")
      |> Bucket.put(2, "Bread")

    assert %Bucket{name: "shopping list 1", data: %{1 => "Milk", 2 => "Bread"}} == bucket
  end

  test "find somthing in a bucket by key" do
    bucket =
      Bucket.bucket("shopping list 3")
      |> Bucket.put(1, "Milk")
      |> Bucket.put(2, "Bread")
      |> Bucket.commit

    assert "Milk" == Bucket.get("shopping list 3", 1)
    assert "Bread" == Bucket.get("shopping list 3", 2)
  end

  test "bucket persists data on commit" do
    Bucket.bucket("shopping list 4")
    |> Bucket.put(1, "Milk")
    |> Bucket.put(2, "Bread")
    |> Bucket.commit()

    assert %Bucket{name: "shopping list 4", data: %{1 => "Milk", 2 => "Bread"}} ==
             Bucket.bucket("shopping list 4")
  end

  test "no other bucket is killed if a bucket dies" do
    # Given
    Bucket.bucket("list 1")
    Bucket.bucket("list 2")
    [{pid1, _}] = Registry.lookup(Bucketier.Registry, "list 1")
    [{pid2, _}] = Registry.lookup(Bucketier.Registry, "list 2")

    # When
    Process.flag(:trap_exit, true)
    Process.exit(pid1, :kill)

    # Then
    refute Process.alive?(pid1)
    assert Process.alive?(pid2)
    assert %Bucket{name: "list 2", data: %{}} == Bucket.bucket("list 2")
  end
end
