defmodule VejperWeb.HtmlHelpers do
  def check_owner(%{user_id: user_id}, %{assigns: %{current_user: %{id: id}}}) do
    user_id == id
  end

  def check_owner(_resource, _conn) do
    false
  end
end

