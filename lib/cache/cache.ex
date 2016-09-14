defmodule Cache do
  def get({module, pid}, key, opts \\ []) do
    case module.get(pid, key) do
      {:found, {value, timestamp: cached_timestamp}} ->
        if stale?(cached_timestamp, opts[:at_least]) do
          :not_found
        else
          {:found, value}
        end
      _ -> :not_found
    end
  end

  defp stale?(_, nil),           do: false
  defp stale?(nil, _),           do: true
  defp stale?(cached, at_least), do: cached < at_least

  def set({module, pid}, key, value, opts \\ []) do
    module.set(pid, key, {value, timestamp: opts[:timestamp]})
  end

  def write_through(cache, key, opts \\ [], value_fn) do
    case get(cache, key, at_least: opts[:at_least]) do
      :not_found ->
        case value_fn.() do
          {:cache, result} ->
            :ok = set(cache, key, result, timestamp: opts[:timestamp])
            result
          {:dont_cache, result} -> result
        end

      {:found, result} -> result
    end
  end
end
