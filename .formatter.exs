[
  import_deps: [:ecto, :ecto_sql, :tesla],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 80,
  subdirectories: ["priv/*/migrations"]
]
