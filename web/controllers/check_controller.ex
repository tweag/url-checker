defmodule LinkChecker.CheckController do
  use LinkChecker.Web, :controller

  def index(conn, %{ "url" => url } = params) do
    response = HTTPotion.get(url, follow_redirects: true)

    conn
    |> put_status(response.status_code)
    |> json %{ url: url, status: response.status_code }
  end
end
