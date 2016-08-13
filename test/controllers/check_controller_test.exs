defmodule LinkChecker.CheckControllerTest do
  use LinkChecker.ConnCase

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

  test "a redirect to a success", %{conn: conn} do
    assert_response conn, httpbin("redirect/2"), 200
  end

  test "a redirect to an error", %{conn: conn} do
    error_url = url_with_status(400)
    assert_response conn, httpbin("redirect-to?url=#{error_url}"), 400
  end

  test "202 No Content is an error", %{conn: conn} do
    assert_response conn, url_with_status(202), 404, 202
  end

  test "4xx codes get passed on", %{conn: conn} do
    for status <- 400..431 do
      assert_response conn, url_with_status(status), status
    end
  end

  test "5xx are passed through", %{conn: conn} do
    for status <- 500..511 do
      assert_response conn, url_with_status(status), status
    end
  end

  test "a host that does not exist returns 404", %{conn: conn} do
    assert_response conn, "http://doesnotexist-3453532342435.com", 404, 0
  end
end
