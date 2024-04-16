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
