defmodule URLChecker.CheckController do
  use URLChecker.Web, :controller

  def index(conn, %{ "url" => url } = params) do
    %{return: return_status, report: report} =
      URLChecker.Checker.check(url,
       timestamp: parse_timestamp(params["timestamp"]),
       at_least:  parse_timestamp(params["at_least"]),
       cache: {Cache.Redis, URLChecker.Redis})

    conn
    |> put_status(return_status)
    |> json(report)
  end

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(str) do
    {value, ""} = Float.parse(str)
    value
  end
end
