# Bucketier README

**Bucketier** is a simple _Dictionary_ application you can use to store
data in a simple _Bucket_ (Key/Value store).

See `Bucketier.Bucket` for more information.


## Installation

Bucketier is [available as hex package](https://hex.pm/packages/bucketier), 
the package can be installed by adding `bucketier` to your list of dependencies 
in `mix.exs` and optionally start it with your application:

```elixir
def application do
  [
    applications: [:bucketier],     ### add :bucketier here
    extra_applications: [:logger],
    mod: {YourElixirApp.Application, []}
  ]
end

def deps do
  [
    {:bucketier, "~> 0.1.0"}
  ]
end

```

Documentation can be found at [https://hexdocs.pm/bucketier](https://hexdocs.pm/bucketier).

## Examples

The best way to figure out how you can use this library is by having a look at 
this [Test suite](https://github.com/iboard/hexpack-examples/blob/master/test/hexpack_examples_test.exs).


### Put some items in a shopping list and retreive the bucket by name

```elixir
    alias Bucketier.Bucket
    
    Bucket.bucket("shopping list")
    |> Bucket.put( 1, "Milk")
    |> Bucket.put( 2, "Butter")
    |> Bucket.put( 3, "Bread")
    |> Bucket.commit

    Bucket.bucket("shopping list")
    #=> %Bucketier.Bucket{ 
    #=>  data: %{ 1 => "Milk", 2 => "Butter", 3 => "Bread"}, 
    #=>  name: "shopping list"
    #=> }
```

`Bucket.bucket("bucket name")` will return a struct of type `%Bucket{}`.
`Bucket.put` will add keys to this structure but will not save the new
state to the `Bucketier` until you call `Bucket.commit(mybucket)`.

### Put some items in a list and retreive values by keys later

```elixir
    alias Bucketier.Bucket
    
    Bucket.bucket("shopping list")
    |> Bucket.put( 1, "Milk")
    |> Bucket.put( 2, "Butter")
    |> Bucket.put( 3, "Bread")
    |> Bucket.commit

    Bucket.get("shopping list", 2)
    #=> "Butter"

    Bucket.keys("shopping list")
    #=> [1,2,3]

    Bucket.values("shopping list")
    #=> ["Milk, "Butter", "Bread"]
```


## Roadmap

The project is a sidekick from a project at our company and will hopefully
mature over the next weeks.

Obviously, updating and deleting of entries, real persistence (on disc),
and other features are missing and will follow.

    

