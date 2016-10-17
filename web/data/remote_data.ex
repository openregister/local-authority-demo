defmodule RemoteData do

  def clear_cache do
    for {key,_} <- ConCache.ets(:my_cache) |> :ets.tab2list do
      ConCache.delete(:my_cache, key)
    end
  end

  def data_list kind do
    path = System.get_env("DATA_FILE")
    url = "https://raw.githubusercontent.com/openregister/#{path}"
    file_path = "../#{path}" |> String.replace("/master","")
    list = ConCache.get_or_store(:my_cache, kind, get_list(url, file_path, kind))
    [page_url(url), list]
  end

  def maps_list do
    maps_index
    |> Map.keys
    |> Enum.map(&map_list/1)
  end

  def maps_index do
    ConCache.get_or_store(:my_cache, "index", get_maps_index)
  end

  defp page_url url do
    url
    |> String.replace("raw.githubusercontent.com/openregister", "github.com/openregister/")
    |> String.replace("/master/", "/blob/master/")
  end

  defp maps_url_and_path file do
    path = System.get_env("MAPS_PATH")
    url = "https://raw.githubusercontent.com/openregister/#{path}/#{file}"
    file_path = "../#{path}/#{file}" |> String.replace("/master","")
    [url, file_path]
  end

  defp map_list file do
    [url, file_path] = maps_url_and_path("#{file}.tsv")
    list = ConCache.get_or_store(:my_cache, file, get_list(url, file_path, file))
    [file, page_url(url), list]
  end

  defp get_maps_index do
    [url, file_path] = maps_url_and_path("index.yml")
    fn () ->
      url
      |> retrieve_data(file_path)
      |> YamlElixir.read_from_string
    end
  end

  defp retrieve_data url, file_path do
    try do
      IO.puts url
      HTTPoison.get!(url).body
    rescue
      HTTPoison.Error ->
        IO.puts file_path
        {:ok, body} = File.read(file_path)
        body
    end
  end

  defp remove_register_curie_prefix text do
    text
    |> String.replace(~r/local-authority-(eng|wls|sct|nir):/, "")
  end

  defp remove_register_country_suffix text do
    text
    |> String.replace(~r/local-authority-(eng|wls|sct|nir)/, "local-authority")
  end

  defp get_list url, file_path, kind do
    fn () ->
      url
      |> retrieve_data(file_path)
      |> String.replace_trailing("\n", "")
      |> remove_register_curie_prefix
      |> remove_register_country_suffix
      |> DataMorph.structs_from_tsv(OpenRegister, kind)
      |> Enum.to_list
    end
  end
end
