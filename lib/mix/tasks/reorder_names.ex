defmodule Mix.Tasks.ReorderNames do
  use Mix.Task

  @data_path "#{System.cwd!()}/priv/repo/initial_data/names.json"
  @tmp_path "#{System.cwd!()}/priv/repo/initial_data/tmp.json"

  def run(_) do
    obtain_names()
    |> mix_names_by_gender()
    |> store_names()
  end

  defp mix_names_by_gender(names) do
    names
    |> Enum.split_with(&(&1["gender"] == "male"))
    |> merge_names
  end

  defp merge_names({male_group, female_group}) do
    merged_names = merge_names(male_group, female_group, [])
    Enum.reverse(merged_names)
  end

  defp merge_names([], [], acc), do: acc

  defp merge_names([name | rest_names], [], acc) do
    merge_names(rest_names, [], [name | acc])
  end

  defp merge_names([], [name | rest_names], acc) do
    merge_names([], rest_names, [name | acc])
  end

  defp merge_names([l_name | rest_l_names], [r_name | rest_r_names], acc) do
    merge_names(rest_l_names, rest_r_names, [l_name | [r_name | acc]])
  end

  defp obtain_names do
    File.read!(@data_path)
    |> Poison.decode!()
  end

  defp store_names(names) do
    encoded_names = Poison.encode!(names)
    File.write!(@tmp_path, encoded_names)
  end
end
