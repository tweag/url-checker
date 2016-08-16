defmodule URLChecker.CheckerTest do
  use ExUnit.Case

  import URLChecker.Checker

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

  test "Most codes get passed through" do
    for range <- [400..431, 500..511, 520..526, [999]] do
      for status <- range do
        result = check(url_with_status(status))

        assert result[:return] == status
        assert result[:report][:status] == status
      end
    end
  end

  test "a host that does not exist returns 404" do
    result = check("http://localhost:2")

    assert result[:return] == 404
    assert result[:report][:status] == 0
  end

  test "accepts a module definition for HTTP provider [sanity check]" do
    assert_raise UndefinedFunctionError, fn ->
      check(url_with_status(200), http: :none)
    end
  end

  test "caches successful results" do
    url = url_with_status(200)
    cache = Cache.Memory.new

    with_http    = fn -> check(url, cache: cache) end
    without_http = fn -> check(url, cache: cache, http: :none) end

    original_result = with_http.()
    cached_result   = without_http.()

    assert original_result == cached_result
  end

  test "does not cache unsuccessful results" do
    good_url = url_with_status(200)
    bad_url  = url_with_status(400)

    cache = Cache.Memory.new

    check(good_url, cache: cache)
    check(bad_url,  cache: cache)

    {:found, _} = Cache.get(cache, good_url)
    :not_found  = Cache.get(cache, bad_url)
  end

  test "uses a User Agent that does not set off alarms for sites" do
    result = check("https://2013.nashville.wordcamp.org/")
    assert result[:report][:status] == 200
  end
end
