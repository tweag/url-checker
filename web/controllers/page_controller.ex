defmodule URLChecker.PageController do
  use URLChecker.Web, :controller

  def index(conn, _params) do
    text conn, "hello"
  end
end
