Code.require_file "test/cache/implementation_test.exs"

defmodule CacheTest.Memory do
  use CacheTest.Implementation

  setup _tags do
    {:ok, cache_pid} = Cache.Memory.start_link

    {:ok, cache_module: Cache.Memory, cache: cache_pid}
  end
end
