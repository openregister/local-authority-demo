defmodule DataDemo.PageController do
  use DataDemo.Web, :controller

  def index(conn, params) do
    country = params["country"]
    case country do
      "eng" ->
        render_report conn, country
      "nir" ->
        render_report conn, country
      "sct" ->
        render_report conn, country
      "wls" ->
        render_report conn, country
      nil ->
        render conn, "home.html"
      _ ->
        text conn, "not found"
    end
  end

  defp render_report conn, country do
    kind = Module.concat(LocalAuthority, country |> String.capitalize)
    [data_url, data_list] = RemoteData.data_list(kind, country)

    render conn, "index.html",
          data_url: data_url,
          data_list: data_list,
          data_list_by_id: data_list |> Enum.group_by(&(&1.local_authority)),
          maps_list: RemoteData.maps_list,
          description: RemoteData.maps_index,
          country: country
  end

  def clear_cache(conn, _params) do
    RemoteData.clear_cache()
    text conn, "Cache cleared"
  end
end
