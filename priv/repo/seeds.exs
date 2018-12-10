# This part inserts a list of scratched names into db to work with
alias BabyNames.Repo
alias BabyNames.Repo.NameDescription

name_descriptions =
  :code.priv_dir(:baby_names)
  |> Path.join("repo/initial_data/names.json")
  |> File.read!()
  |> Poison.decode!()
  |> Enum.map(fn parsed_json ->
    %{
      name: parsed_json["name"],
      description: parsed_json["description"],
      gender: parsed_json["gender"],
      origin: parsed_json["origin"],
      name_dates: parsed_json["nameDates"],
      short_forms: parsed_json["shortForms"],
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end)

Repo.insert_all(NameDescription, name_descriptions)

# end of section
