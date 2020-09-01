defmodule SpyRadio.Headquarters do
  def wait_for_message(channel, queue, exchange) do
    {:ok, _} = AMQP.Queue.declare(channel, queue, durable: true)
    :ok = AMQP.Exchange.fanout(channel, exchange, durable: true)
    :ok = AMQP.Queue.bind(channel, queue, exchange)

    {:ok, _tag} =
      AMQP.Queue.subscribe(channel, queue, fn payload, meta -> handle_message(payload, meta) end)
  end

  def handle_message(payload, _meta) do
    IO.puts("Got super secret message: #{payload}")
  end
end
