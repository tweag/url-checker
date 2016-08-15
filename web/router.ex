defmodule URLChecker.Router do
  use URLChecker.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", URLChecker do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/check", CheckController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", URLChecker do
  #   pipe_through :api
  # end
end
