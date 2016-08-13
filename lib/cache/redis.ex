defmodule Cache.Redis do
  def set(redix, key, value) do
    redix.command(["SET", key, :erlang.term_to_binary(value)])
    :ok
  end

  def get(redix, key) do
    {:ok, result} = redix.command(["GET", key])

    if result do
      {:found, :erlang.binary_to_term(result)}
    else
      :not_found
    end
  end
end
