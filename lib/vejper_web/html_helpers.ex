defmodule VejperWeb.HtmlHelpers do
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
