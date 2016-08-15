defmodule URLChecker.PageController do
  use URLChecker.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
