defmodule Slurp.Application do
  require Logger
  use GenServer

  @camp_url "https://api.patreon.com/oauth2/api/current_user/campaigns"
  @pledge_url "https://api.patreon.com/oauth2/api/campaigns/"

  #Client Calls
  def start_link do
    GenServer.start_link(__MODULE__,[],[])
  end

  def init(_opts) do
    init_state = _config()
    Logger.info "Loaded config; starting..."
    GenServer.cast(self, :run)
    {:ok, init_state}
  end

  #Server calls
  def handle_cast(:run, state) do
    campaign_id = get_campaign(state.token)
    Logger.info "Campaign ID is: #{campaign_id}"
    pledges = get_pledges(campaign_id, state.token)
    :init.stop
    {:noreply, state}
  end

  # Private functions
  defp _config() do
    %{
      :id => Application.get_env(:patreon_slurp, :id),
      :secret => Application.get_env(:patreon_slurp, :secret),
      :token => Application.get_env(:patreon_slurp, :token),
      :refresh => Application.get_env(:patreon_slurp, :refresh)
    }
  end

  defp get_campaign(token) do
    @camp_url |>
      HTTPoison.get!([{"Authorization", "Bearer #{token}"}], [timeout: 10_000, recv_timeout: 10_000]) |>
      Map.get(:body) |>
      Poison.Parser.parse! |>
      Map.get("data") |>
      hd |>
      Map.get("id")
  end

  defp get_pledges(campaign_id, token) do
    #https://api.patreon.com/oauth2/api/campaigns/<campaign_id>/pledges
    #@pledge_url <> campaign_id <> "/pledges" |>
    #  HTTPoison.get!([{"Authorization", "Bearer #{token}"}], [timeout: 20_000, recv_timeout: 10_000]) |>
  end
  defp do_get_pledges(url) do

  end
end
