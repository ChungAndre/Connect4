defmodule Puissance4.Repo do
  use Ecto.Repo,
    otp_app: :puissance4,
    adapter: Ecto.Adapters.Postgres
end
