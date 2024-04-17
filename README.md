# Example

Example app for Blitz

## Setup

### Riot API token

Copy the example environment file and replace the token:

```sh
cp example.env > .envrc
```

### Database

You can also change the specifics in the environment for Postgres or run the
defaults. Then, to create the database simply use the setup alias:

```sh
mix ecto.setup
```

Or call each step manually

```sh
mix ecto.create
mix ecto.migrate
```

## How to use

### Start the server

```sh
iex -S mix run
```

### Quickstart

If you would prefer not to take any of the manual steps to observe the process,
there is one simple helper that will do all of the below and give you back
anything you want to save for future use:

```elixir
%{pid: pid, summoner: summoner, session: session} =
  Example.Lol.watch_summoner("summonername", "na1")
```

### Create a session

All requests need a region and an API token. By using the
`Example.Session.new/2` function, you can store both of these for use with any
call:

```elixir
> Example.Session.new("na1")
%Example.Session{
  __meta__: #Ecto.Schema.Metadata<:built, "session">,
  id: nil,
  region: "na1",
  token: "[encrypted token]"
}
```

> Note: Use the shorthand region. The API module will automatically find the
> related broad region where necessary.

> Note: The token automatically uses the token in your environment, but you may
> provide it as a second argument if you would prefer to establish it at the start
> of each session or override your local env.

### Make a single request

For League of Legends requests, use the `Example.Lol` module. This will make any
necessary API requests as well as store the necessary summoner data in the
database for caching.

The `Example.Lol` module takes a session as its first argument in all cases, so
you can pipe the creation or pass the variable.

### Watch for summoner matches

Once you have a session, you can create a summoner in the database by searching
for the puuid using the name:

```elixir
> name = "summonername"
"summonername"
> {:ok, puuid} = Example.Lol.summoner_puuid(session, name)
{:ok, "[encryped puuid]"}
> summoner = Example.Summoner.get_by_puuid(puuid)
%Example.Summoner{
  __meta__: #Ecto.Schema.Metadata<:loaded, "summoner">,
  id: 1,
  riot_id: "[encrypted riot id]",
  account_id: "[encrypted account name]",
  puuid: "[encrypted puuid]",
  name: "summonername",
  inserted_at: ~N[2024-01-01 12:00:00],
  updated_at: ~N[2024-01-01 12:00:00]
}
```

Now that you have your session established with region and token as well as a
summoner to watch, we can start a polling process to watch for new matches and
get participants:

```elixir
> {:ok, pid} = Poll.start_link(session, summoner)
[lots of query output]
[summoner_1, summoner_2, ...etc.]
{:ok, #PID<0.100.0>}
```

This will start the process and log out all the current list of other summoners
in the past 5 matches.

If you're extra curious, you can even trace the process to watch for state
changes:

```elixir
> :sys.trace(pid, true)
:ok
```
