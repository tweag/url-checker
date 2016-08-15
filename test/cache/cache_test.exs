defmodule CacheTest do
  use ExUnit.Case

  setup _tags do
    {:ok, cache: Cache.Memory.new}
  end

  test "set values", %{cache: cache} do
    Cache.set cache, "key", "value"
    Cache.set cache, "other key", "other value"

    assert Cache.get(cache, "key") == {:found, "value"}
    assert Cache.get(cache, "other key") == {:found, "other value"}
  end

  test "sets an existing value", %{cache: cache} do
    Cache.set cache, "key", "old value"
    Cache.set cache, "key", "new value"

    assert Cache.get(cache, "key") == {:found, "new value"}
  end

  test "get unset value", %{cache: cache} do
    assert :not_found = Cache.get(cache, "key")
  end

  test "get when the cached timestamp is younger than acceptable", %{cache: cache} do
    Cache.set cache, "key", "value", timestamp: 2016
    assert Cache.get(cache, "key", at_least: 2015) == {:found, "value"}
  end

  test "get when the cached timestamp is the same as the acceptable timestamp", %{cache: cache} do
    Cache.set cache, "key", "value", timestamp: 2016
    assert Cache.get(cache, "key", at_least: 2016) == {:found, "value"}
  end

  test "get when the cached timestamp is older than acceptable", %{cache: cache} do
    Cache.set cache, "key", "value", timestamp: 2015
    assert Cache.get(cache, "key", at_least: 2016) == :not_found
  end

  test "get when the cached timestamp was not set and the acceptable timestamp is not set", %{cache: cache} do
    Cache.set cache, "key", "value"
    assert Cache.get(cache, "key") == {:found, "value"}
  end

  test "get when the cached timestamp was not set but the acceptable timestamp is", %{cache: cache} do
    Cache.set cache, "key", "value"
    assert Cache.get(cache, "key", at_least: 2016) == :not_found
  end

  test "write_through obeys timestamps when setting", %{cache: cache} do
    Cache.write_through cache, "key", [timestamp: 2016], fn -> {:cache, "value"} end

    assert Cache.get(cache, "key", at_least: 2015) == {:found, "value"}
    assert Cache.get(cache, "key", at_least: 2017) == :not_found
  end

  test "write_through obeys timestamps when getting and the cache is fresh", %{cache: cache} do
    Cache.set cache, "key", "original value", timestamp: 2015

    result = Cache.write_through cache, "key", [timestamp: 2016, at_least: 2014], fn -> {:cache, "new value"} end
    assert result == "original value"
  end

  test "write_through obeys timestamps when getting and the cache is stale", %{cache: cache} do
    Cache.set cache, "key", "original value", timestamp: 2015

    result = Cache.write_through cache, "key", [timestamp: 2016, at_least: 2016], fn -> {:cache, "new value"} end
    assert result == "new value"
  end

  test "write_through updates timestamps, too, when overwriting", %{cache: cache} do
    Cache.set cache, "key", "original value", timestamp: 2015

    Cache.write_through cache, "key", [timestamp: 2016, at_least: 2016], fn -> {:cache, "new value"} end

    assert Cache.get(cache, "key") == {:found, "new value"}
  end

  test "writes through, caching the value", %{cache: cache} do
    result = Cache.write_through cache, "key", fn -> {:cache, "value"} end

    assert result == "value"
    assert Cache.get(cache, "key") == {:found, "value"}
  end

  test "writes through, not caching the value", %{cache: cache} do
    result = Cache.write_through cache, "key", fn -> {:dont_cache, "value"} end
    assert result == "value"
    assert Cache.get(cache, "key") == :not_found
  end

  test "writes through, not executing function if key is already set", %{cache: cache} do
    Cache.set cache, "key", "original value"
    result = Cache.write_through cache, "key", fn -> raise "SHOULD NOT RUN" end
    assert result == "original value"
  end
end
