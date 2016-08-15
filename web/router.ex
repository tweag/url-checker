defmodule URLChecker.Router do
  use URLChecker.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/", URLChecker do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/check", CheckController, :index
  end
end
