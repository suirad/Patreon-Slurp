# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :patreon_slurp, token: ""
config :patreon_slurp, output_file: ~S(<path-here>) #Takes an absolute path, should look like ~S(C:\path) with no quotations

config :patreon_slurp, name_swaps:
  [
    {"name", "swapped name"},
    {"othername", "other swapped name"},
    {"Darius", "Suirad"}
  ]
