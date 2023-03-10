defmodule VejperWeb.UserLoginLive do
  use VejperWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Prijava
        <:subtitle>
          Nemate nalog?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Napravite
          </.link>
          novi nalog.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Lozinka" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Ostavi me prijavljenu/nog" />
          <.link
            href={~p"/users/reset_password"}
            class="dark:text-zinc-200 dark:hover:text-zinc-300 text-sm font-semibold"
          >
            Zaboravljena lozinka?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Prijava u toku..." class="w-full">
            Prijavi se <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{email: email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end