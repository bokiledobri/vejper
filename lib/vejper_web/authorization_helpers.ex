defmodule VejperWeb.AuthorizationHelpers do
  use VejperWeb, :verified_routes

  def on_mount(:ensure_profile_completed, _params, _session, socket) do
    if socket.assigns.current_user && socket.assigns.current_user.profile do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          "Molimo dovršite pravljenje profila da biste pristupili ovoj stranici."
        )
        |> Phoenix.LiveView.redirect(to: ~p"/profili/novi")

      {:halt, socket}
    end
  end

  def on_mount(:ensure_profile_completed_for_mutating, _params, _session, socket) do
    if socket.assigns.current_user && socket.assigns.current_user.profile do
      {:cont, socket}
    else
      if socket.assigns.live_action in [:new, :edit] do
        socket =
          socket
          |> Phoenix.LiveView.put_flash(
            :error,
            "Molimo dovršite pravljenje profila da biste pristupili ovoj stranici."
          )
          |> Phoenix.LiveView.redirect(to: ~p"/profili/novi")

        {:halt, socket}
      else
        {:cont, socket}
      end
    end
  end

  def require_authenticated_user(socket) do
    if socket.assigns.current_user do
      socket
    else
      redirect_unauthenticated(socket)
    end
  end

  def require_profile_completed(socket) do
    if socket.assigns.current_user do
      if socket.assigns.current_user.profile do
        socket
      else
      end

      redirect_unfinished_profile(socket)
    else
      redirect_unauthenticated(socket)
    end
  end

  defp redirect_unfinished_profile(socket) do
    socket
    |> Phoenix.LiveView.put_flash(
      :error,
      "Molimo dovršite pravljenje profila da biste pristupili ovoj stranici."
    )
    |> Phoenix.LiveView.redirect(to: ~p"/profili/novi")
  end

  defp redirect_unauthenticated(socket) do
    socket
    |> Phoenix.LiveView.put_flash(
      :error,
      "Morate biti prijavljeni da biste pristupili ovoj stranici"
    )
    |> Phoenix.LiveView.redirect(to: ~p"/nalog/prijava")
  end

  def owner?(_, %{assigns: %{current_user: %{role: :admin}}}) do
    true
  end

  def owner?(%{user_id: user_id}, %{assigns: %{current_user: %{id: id}}}) do
    user_id == id
  end

  def owner?(_resource, _conn) do
    false
  end

  def is_owner?(_resource, %{role: :admin}) do
    true
  end

  def is_owner?(%{user_id: user_id}, %{id: id}) do
    user_id == id
  end

  def is_owner?(_resource, _user) do
    false
  end

  def admin?(%{assigns: %{current_user: %{role: :admin}}}) do
    true
  end

  def admin?(_conn) do
    false
  end

  def is_admin?(%{role: :admin}) do
    true
  end

  def is_admin?(_user) do
    false
  end

  def chat_mod?(%{assigns: %{current_user: %{role: :admin}}}) do
    true
  end

  def chat_mod?(%{assigns: %{current_user: %{mods: mods}}}) when is_list(mods) do
    Enum.any?(mods, fn mod -> mod == :chat end)
  end

  def chat_mod?(_conn) do
    false
  end

  def is_chat_mod?(%{role: :admin}) do
    true
  end

  def is_chat_mod?(%{mods: mods}) when is_list(mods) do
    Enum.any?(mods, fn mod -> mod == :chat end)
  end

  def is_chat_mod?(_user) do
    false
  end

  def store_mod?(%{assigns: %{current_user: %{role: :admin}}}) do
    true
  end

  def store_mod?(%{assigns: %{current_user: %{mods: mods}}}) when is_list(mods) do
    Enum.any?(mods, fn mod -> mod == :ads end)
  end

  def store_mod?(_conn) do
    false
  end

  def is_store_mod?(%{role: :admin}) do
    true
  end

  def is_store_mod?(%{mods: mods}) when is_list(mods) do
    Enum.any?(mods, fn mod -> mod == :ads end)
  end

  def is_store_mod?(_user) do
    false
  end

  def social_mod?(%{assigns: %{current_user: %{role: :admin}}}) do
    true
  end

  def social_mod?(_conn) do
    false
  end

  def is_social_mod?(%{role: :admin}) do
    true
  end

  def is_social_mod?(_user) do
    false
  end
end
