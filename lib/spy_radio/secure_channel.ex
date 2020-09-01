defmodule SpyRadio.SecureChannel do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> __MODULE__.new() end, name: __MODULE__)
  end

  def new do
    {:ok, conn} = AMQP.Connection.open()
    %{connection: conn, channels: %{}}
  end

  def connect(pid) do
    %{connection: conn, channels: channel_map} = get_state()
    new_channel_map = maybe_new_channel(channel_map, Map.has_key?(channel_map, pid), conn, pid)
    newState = %{connection: conn, channels: new_channel_map}
    Agent.update(__MODULE__, fn _state -> newState end)
    {:ok, new_channel_map[pid]}
  end

  defp maybe_new_channel(map, true, _conn, _pid), do: map

  defp maybe_new_channel(map, false, conn, pid) do
    {:ok, chan} = AMQP.Channel.open(conn)
    Map.put(map, pid, chan)
  end

  def get_state do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
