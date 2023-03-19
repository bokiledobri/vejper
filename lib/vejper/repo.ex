defmodule Vejper.Repo do
  use Ecto.Repo,
    otp_app: :vejper,
    adapter: Ecto.Adapters.Postgres

  use Paginator
end
