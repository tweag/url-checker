defmodule LinkChecker.PageController do
  use LinkChecker.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
