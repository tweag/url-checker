Code.require_file "test/cache/implementation_test.exs"

defmodule Cache.RedisTest do
  use CacheTest.Implementation

  setup _tags do
    LinkChecker.Redis.command ["FLUSHDB"]

    {:ok, cache_module: Cache.Redis, cache: LinkChecker.Redis}
  end
end
