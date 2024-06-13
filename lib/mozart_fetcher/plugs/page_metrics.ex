defmodule MozartFetcher.Plug.PageMetrics do
  @behaviour Plug
  import Plug.Conn, only: [register_before_send: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    before_time = System.monotonic_time(:millisecond)
    :telemetry.execute([:web, :request, :count], %{})

    register_before_send(conn, fn conn ->
      timing = (System.monotonic_time(:millisecond) - before_time) |> abs

      :telemetry.execute([:web, :response, :status], %{}, %{status_code: conn.status})

      :telemetry.execute([:web, :response, :timing], %{duration: timing}, %{
        status_code: conn.status
      })

      :telemetry.execute([:web, :response, :timing, :page], %{duration: timing}, %{})
      conn
    end)
  end
end
