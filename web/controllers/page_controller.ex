defmodule DataDemo.PageController do
  use DataDemo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
