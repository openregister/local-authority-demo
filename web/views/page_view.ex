defmodule DataDemo.PageView do
  use DataDemo.Web, :view

  def fields entities do
    entities
    |> Enum.at(0)
    |> Map.keys
    |> Enum.filter(&(&1 != :__struct__ and &1 != :local_authority))
    |> Enum.sort
    |> Enum.join(" ")
  end

  def count_in list, function do
    list
    |> Enum.filter(&(function.(&1)))
    |> Enum.count
  end

  def label_type_name item do
    "#{item.local_authority_type} #{item.name}"
  end

  def label_type item do
    item.local_authority_type
  end

  def label_name item do
    item.name
  end

  def england_or_wales do
    fn item -> (item.uk == "ENG" || item.uk == "WLS") && !end_date_present.(item) end
  end

  def england do
    fn item -> item.uk == "ENG" && !end_date_present.(item) end
  end

  def wales do
    fn item -> item.uk == "WLS" && !end_date_present.(item) end
  end

  def scotland do
    fn item -> item.uk == "SCT" && !end_date_present.(item) end
  end

  def northern_ireland do
    fn item -> item.uk == "NIR" && !end_date_present.(item) end
  end

  def end_date_present do
    fn item -> item.end_date |> String.length > 0 end
  end

  def local_authority entity, authorities_by_id do
    case Map.get(authorities_by_id, entity.local_authority) do
      nil -> nil
      authority -> authority |> Enum.at(0)
    end
  end

  def local_authorities list, authorities_by_id do
    list
    |> Enum.map(&(&1 |> local_authority(authorities_by_id)))
    |> Enum.filter(&(&1))
  end

  defp file_to_id file do
    file
    # |> Atom.to_string
    |> String.replace("-","_")
    |> String.replace("food_standards","food_authority")
    |> String.to_atom
  end

  def match_from_list list, authority do
    list
    |> Enum.find(&(&1.local_authority == authority.local_authority))
  end

  def legacy_code_for item, file do
    Map.get item, file_to_id(file)
  end

  defp normalise name do
    name |> String.downcase
  end

  defp legacy_name_for item, name do
    if normalise(item.name) == normalise(name) do
      nil
    else
      "<b>#{item.name}</b>"
    end
  end

  defp item_label item, file, name do
    try do
      [legacy_code_for(item, file), legacy_name_for(item, name)]
      |> Enum.filter(&(&1))
      |> Enum.join(" <br /> ")
    rescue
      KeyError -> ""
    end
  end

  def local_authority_name list, authority, file do
    case match_from_list(list, authority) do
      nil -> nil
      item -> item_label(item, file, authority.name)
    end
  end

  def match_count data, authority do
    matches = data
    |> Enum.map( fn(row) ->
      [file, _, list] = row
      list |> local_authority_name(authority, file)
    end)
    |> Enum.filter(&(&1))
    |> Enum.count
  end

  def authorities authorities_by_id do
    authorities_by_id
    |> Map.values
    |> Enum.map(&List.first/1)
    |> Enum.sort_by(&([&1.uk, &1.local_authority]))
  end

end
