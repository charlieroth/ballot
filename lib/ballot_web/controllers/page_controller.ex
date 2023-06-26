defmodule BallotWeb.PageController do
  use BallotWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
