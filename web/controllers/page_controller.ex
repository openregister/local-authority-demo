defmodule DataDemo.PageController do
  use DataDemo.Web, :controller

  def index(conn, _params) do
    data_list = RemoteData.data_list(LocalAuthority)

    render conn, "index.html",
          data_list: data_list,
          data_list_by_id: data_list |> Enum.group_by(&(&1.local_authority)),
          maps_list: RemoteData.maps_list,
          description: RemoteData.maps_index
  end
end
