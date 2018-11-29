# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DataProcessor.Repo.insert!(%DataProcessor.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias DataProcessor.Repo
alias DataProcessor.InterSCity
alias DataProcessor.InterSCity.JobTemplate
alias DataProcessor.Coherence.User

params = %{
  name: "Test User",
  email: "testuser@example.com",
  password: "secret",
  password_confirmation: "secret"
}

Repo.delete_all User
User.changeset(%User{}, params)
|> Repo.insert!

kmeans_handler = DataProcessor.Handlers.KMeans
kmeans_params = %{
  title: "k-Means template",
  handler: "#{kmeans_handler}",
  params: %{
    schema: %{lat: "double", lon: "double"},
    publish_strategy: %{name: "file", format: "csv"},
    functional_params: %{features: "lat,lon"},
    interscity: %{capability: "geolocalization"}
  }
}
JobTemplate.changeset(%JobTemplate{}, kmeans_params)
|> Repo.insert!
