defmodule LinkChecker.CheckerTest do
  use ExUnit.Case

  import LinkChecker.Checker

  defp url_with_status(status), do: httpbin("status/#{status}")

  defp httpbin(path), do: "http://httpbin.org/#{path}"

  test "a successful response" do
    result = check(url_with_status(200))

    assert result[:return] == 200
    assert result[:report][:status] == 200
  end

  test "a redirect to a success" do
    result = check(httpbin("redirect/2"))

    assert result[:return] == 200
    assert result[:report][:status] == 200
  end

  test "a redirect to an error" do
    error_url = url_with_status(400)
    result = check(httpbin("redirect-to?url=#{error_url}"))

    assert result[:return] == 400
    assert result[:report][:status] == 400
  end

  test "202 No Content is an error" do
    result = check(url_with_status(202))

    assert result[:return] == 404
    assert result[:report][:status] == 202
  end

  test "4xx and 5xx codes get passed through" do
    for range <- [400..431, 500..511, 520..526] do
      for status <- range do
        result = check(url_with_status(status))

        assert result[:return] == status
        assert result[:report][:status] == status
      end
    end
  end

  test "a host that does not exist returns 404" do
    result = check("http://doesnotexist-3453532342435.com")

    assert result[:return] == 404
    assert result[:report][:status] == 0
  end
end
