defmodule PatreonSlurp do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Slurp.Supervisor.start_link
  end
  def main(_args) do
    Application.ensure_all_started(:patreon_slurp)
    GenServer.call(:slurp, :run, 60_000)
  end

end
