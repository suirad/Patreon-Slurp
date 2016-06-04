defmodule Slurp.Application do
  use GenServer

  @camp_url "https://api.patreon.com/oauth2/api/current_user/campaigns"
  @pledge_url "https://api.patreon.com/oauth2/api/campaigns/"
  @user_url "https://api.patreon.com/user/"

  #Client Calls
  def start_link do
    GenServer.start_link(__MODULE__,[],[])
  end

  def init(_opts) do
    init_state = get_config()
    IO.puts "Loaded config; starting..."
    Process.register(self, :slurp)
    {:ok, init_state}
  end

  #Server calls
  def handle_call(:run, _from,  state) do
    campaign_id = get_campaign(state.token)
    IO.puts "Campaign ID is: #{campaign_id}"
    pledges = get_pledges(campaign_id, state.token, state.swaps)
    save_pledges(state.output_file, pledges)
    IO.puts "Total Pledges: #{Enum.count pledges}"
    {:reply, :ok, state}
  end

  # Private functions
  defp get_config() do
    %{
      :token => Application.get_env(:patreon_slurp, :token),
      :output_file => Application.get_env(:patreon_slurp, :output_file) |> Path.absname,
      :swaps => Application.get_env(:patreon_slurp, :name_swaps)
    }
  end

  defp request(url, token) do
    HTTPoison.get!(url,[{"Authorization", "Bearer #{token}"}], [timeout: 10_000, recv_timeout: 10_000])
  end

  defp get_campaign(token) do
    @camp_url
      |> request(token)
      |> Map.get(:body)
      |> Poison.Parser.parse!
      |> Map.get("data")
      |> Kernel.hd()
      |> Map.get("id")
  end

  defp get_pledges(campaign_id, token, swaps) do
    do_get_pledges_raw(@pledge_url <> campaign_id <> "/pledges",token)
      |> do_get_pledges_filter(token, swaps)
  end

  defp do_get_pledges_raw(nil, _token), do: []
  defp do_get_pledges_raw(url, token) do
    req_data = url
      |> request(token)
      |> Map.get(:body)
      |> Poison.Parser.parse!
    nextlink = Map.get(req_data, "links") |> Map.get("next")
    Map.get(req_data, "data") ++ do_get_pledges_raw(nextlink,token)
  end

  defp do_get_pledges_filter(pledges,token,swaps) do
    pledges
      |> Enum.reduce([], fn(raw_pledge, acc) ->
        cents = Map.get(raw_pledge,"attributes")
          |> filter_cents
        name = Map.get(raw_pledge, "relationships")
          |> Map.get("patron")
          |> Map.get("data")
          |> filter_id
          |> id_to_name(token)
          |> swap_name(swaps)
        pair(name, cents) ++ acc
        end)
  end
  defp filter_cents(%{"amount_cents"=> nil}), do: -1
  defp filter_cents(%{"amount_cents" => cents}), do: cents
  defp filter_cents(_), do: -1
  defp filter_id(%{"id" => nil}), do: -1
  defp filter_id(%{"id" => id}), do: id
  defp filter_id(_), do: -1
  defp pair(id, cents) when is_nil(id) == false and cents > -1, do: [{id, cents}]
  defp pair(_,_), do: []

  defp id_to_name(-1,_), do: nil
  defp id_to_name(id, token) do
    request(@user_url <> id,token)
      |> Map.get(:body)
      |> Poison.Parser.parse!
      |> Map.get("data")
      |> Map.get("full_name")
  end

  defp swap_name(nil,_), do: nil
  defp swap_name(name,swaps) do
    Enum.find_value(swaps,name,
      fn (swap) ->
        {actual, new} = swap
        case actual == name do
          true -> new
          false -> nil
        end
      end)
  end

  defmacro os_sep do
    case :os.type do
      {:win32, _} -> quote do '\r\n' end
      {_, _} -> quote do '\n' end
    end
  end

  defp save_pledges(filename, pledges) do
    f = File.open!(filename, [:write, :utf8])
    final_pledges = pledges
      |> Enum.reduce([],
        fn (pledge, acc) ->
          {name, cents} = pledge
          acc ++ [String.to_char_list(name), os_sep, Integer.to_char_list(cents), os_sep]
        end)
    IO.puts f, final_pledges
    File.close f
  end

end
