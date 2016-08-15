defmodule URLChecker.Redis do
  def pool_size, do: 15 # connection limit for free tier on Heroku is 20

  def command(command) do
    Redix.command(:"redis_#{random_index}", command)
  end

  defp random_index do
    rem(System.unique_integer([:positive]), pool_size)
  end
end
