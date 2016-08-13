defmodule LinkChecker.CheckController do
  use LinkChecker.Web, :controller

  def index(conn, %{ "url" => url } = params) do
    %{return: return_status, report: report} = LinkChecker.Checker.check(url, {Cache.Redis, LinkChecker.Redis})

    conn
    |> put_status(return_status)
    |> json(report)
  end
end
