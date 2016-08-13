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

  test "writes through, caching the value", %{cache: cache} do
    result = Cache.write_through cache, "key", fn -> { :cache, "value" } end

    assert result == "value"
    assert Cache.get(cache, "key") == {:found, "value"}
  end

  test "writes through, not caching the value", %{cache: cache} do
    result = Cache.write_through cache, "key", fn -> { :dont_cache, "value" } end
    assert result == "value"
    assert Cache.get(cache, "key") == :not_found
  end

  test "writes through, not executing function if key is already set", %{cache: cache} do
    Cache.set cache, "key", "original value"
    result = Cache.write_through cache, "key", fn -> raise "SHOULD NOT RUN" end
    assert result == "original value"
  end
end
