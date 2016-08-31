defmodule TestCoherence.TestHelpers do
  alias Coherence.{Rememberable}
  import Phoenix.HTML, only: [safe_to_string: 1]
  import Plug.Conn

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Test User",
      email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
      password: "supersecret",
      password_confirmation: "supersecret"
      }, attrs)

    %TestCoherence.User{}
    |> TestCoherence.User.changeset(changes)
    |> TestCoherence.Repo.insert!
  end

  def insert_rememberable(user, attrs \\ %{}) do
    {changeset, series, token} = Rememberable.create_login(user)
    changes = changeset.changes
    changes = Dict.merge(%{
      user_id: user.id,
      series_hash: changes[:series_hash],
      token_hash: changes[:token_hash],
      token_created_at: changes[:token_created_at]
      }, attrs)
    r1 = %Rememberable{}
    |> Rememberable.changeset(changes)
    |> TestCoherence.Repo.insert!
    {r1, series, token}
  end

  def floki_link(safe) when is_tuple(safe) do
    safe |> safe_to_string |> floki_link
  end
  def floki_link(string) do
    result = Floki.find(string, "a[href]")
    [href] = Floki.attribute(result, "href")
    {href, Floki.text(result)}
  end


  def handler(conn) do
    conn
    |> assign(:error_handler_called, true)
    |> send_resp(418, "I'm a teapot")
  end
end
