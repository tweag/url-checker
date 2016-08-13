defmodule CacheTest.Implementation do
  use ExUnit.CaseTemplate

  using do
    quote do
      test "set values", %{cache_module: cache_module, cache: cache} do
        cache_module.set cache, "key", "value"
        cache_module.set cache, "other key", "other value"

        assert cache_module.get(cache, "key") == {:found, "value"}
        assert cache_module.get(cache, "other key") == {:found, "other value"}
      end

      test "sets an existing value", %{cache_module: cache_module, cache: cache} do
        cache_module.set cache, "key", "old value"
        cache_module.set cache, "key", "new value"

        assert cache_module.get(cache, "key") == {:found, "new value"}
      end

      test "get unset value", %{cache_module: cache_module, cache: cache} do
        assert cache_module.get(cache, "key") == :not_found
      end

      test "can cache a nil value", %{cache_module: cache_module, cache: cache} do
        cache_module.set cache, "key", nil

        assert cache_module.get(cache, "key") == {:found, nil}
      end

      test "stores terms", %{cache_module: cache_module, cache: cache} do
        term = %{ "a" => :b, c: [d: 1, e: 'fgh'] }
        cache_module.set cache, "key", term

        assert cache_module.get(cache, "key") == {:found, term}
      end
    end
  end
end
