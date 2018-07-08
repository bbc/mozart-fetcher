defmodule MozartFetcher.FakeClient do
  def returning(:success) do
    { :ok, successful_response() }
  end

  def returning(:timeout) do
    { :error, timeout_response() }
  end

  defp successful_response() do
    %HTTPoison.Response{
      status_code: 200,
      body:        "{\"some\":\"data\"}",
      headers:     []
    }
  end

  defp timeout_response() do
    %HTTPoison.Error{reason: :timeout}
  end
end
