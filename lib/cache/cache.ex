defmodule Cache do
  def get({module, pid}, key),        do: module.get(pid, key)
  def set({module, pid}, key, value), do: module.set(pid, key, value)

  def write_through({module, pid}, key, value_fn) do
    case module.get(pid, key) do
      :not_found ->
        case value_fn.() do
          {:cache, result} ->
            :ok = module.set(pid, key, result)
            result
          {:dont_cache, result} -> result
        end

      {:found, result} -> result
    end
  end
end
