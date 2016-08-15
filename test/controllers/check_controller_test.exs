defmodule URLChecker.CheckControllerTest do
  use URLChecker.ConnCase

  setup _tags do
    URLChecker.Redis.command ["FLUSHDB"]

    :ok
  end

  defp assert_response(conn, url, expected_status) do
    assert_response(conn, url, expected_status, expected_status)
  end

  defp assert_response(conn, url, returned_status, reported_status) do
    conn = get(conn, "/check", url: url)
    json = json_response(conn, returned_status)

    assert json["url"]    == url
    assert json["status"] == reported_status
  end

  defp url_with_status(status), do: httpbin("status/#{status}")

  defp httpbin(path), do: "http://httpbin.org/#{path}"

  test "a successful response", %{conn: conn} do
    assert_response conn, url_with_status(200), 200
  end

  test "a failed response", %{conn: conn} do
    assert_response conn, url_with_status(400), 400
  end

  test "caches the results", %{conn: conn} do
    url = url_with_status(200)

    get conn, "/check", url: url, timestamp: "0"

    assert {:found, _} = Cache.get({Cache.Redis, URLChecker.Redis}, url)
    assert {:found, _} = Cache.get({Cache.Redis, URLChecker.Redis}, url, at_least: -1)
    assert :not_found  = Cache.get({Cache.Redis, URLChecker.Redis}, url, at_least: 1)
  end
end
