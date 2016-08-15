Code.require_file "test/cache/implementation_test.exs"

defmodule Cache.RedisTest do
  use CacheTest.Implementation

  setup _tags do
    URLChecker.Redis.command ["FLUSHDB"]

    {:ok, cache_module: Cache.Redis, cache: URLChecker.Redis}
  end
end
