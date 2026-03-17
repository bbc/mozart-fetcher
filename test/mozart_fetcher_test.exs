defmodule MozartFetcherTest do
  use ExUnit.Case

  @fake_cert_file_path "<<cert_file_path>>"
  @fake_key_file_path "<<key_file_path>>"

  test "request_ssl/0 on non-prod environment" do
    certfile = System.get_env("DEV_CERT_PEM")
    assert [certfile: certfile, verify: :verify_none] == MozartFetcher.request_ssl()
  end

  describe "on prod environment" do
    setup do
      System.put_env("cert_file_path", @fake_cert_file_path)
      System.put_env("key_file_path", @fake_key_file_path)
      Application.put_env(:mozart_fetcher, :environment, :prod)

      on_exit(fn ->
        Application.put_env(:mozart_fetcher, :environment, :test)
        System.put_env("cert_file_path", "")
        System.put_env("key_file_path", "")
      end)
    end

    test "request_ssl/0" do
      assert [
               certfile: @fake_cert_file_path,
               keyfile: @fake_key_file_path,
               verify: :verify_none
             ] ==
               MozartFetcher.request_ssl()
    end
  end
end
