defmodule RemoteData do

  def clear_cache do
    for {key,_} <- ConCache.ets(:my_cache) |> :ets.tab2list do
      ConCache.delete(:my_cache, key)
    end
  end

  def data_list kind do
    path = System.get_env("DATA_FILE")
    url = "https://raw.githubusercontent.com/openregister/#{path}"
    ConCache.get_or_store(:my_cache, kind, get_list(url, kind))
  end

  def maps_list do
    maps_index
    |> Map.keys
    |> Enum.map(&( [&1, map_list(&1)] ))
  end

  def maps_index do
    ConCache.get_or_store(:my_cache, "index", get_maps_index)
  end

  defp maps_url file do
    path = System.get_env("MAPS_PATH")
    "https://raw.githubusercontent.com/openregister/#{path}/#{file}"
  end

  defp map_list file do
    url = maps_url "#{file}.tsv"
    ConCache.get_or_store(:my_cache, file, get_list(url, file))
  end

  defp get_maps_index do
    fn () ->
      url = maps_url "index.yml"
      HTTPoison.get!(url).body
      |> YamlElixir.read_from_string
    end
  end

  defp get_list url, kind do
    fn () ->
      HTTPoison.get!(url).body
      |> String.replace_trailing("\n", "")
      |> DataMorph.structs_from_tsv(OpenRegister, kind)
      |> Enum.to_list
    end
  end
end
