defmodule VejperWeb.UserForgotPasswordLive do
  use VejperWeb, :live_view

  alias Vejper.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Zaboravljena lozinka?
        <:subtitle>Poslaćemo vam link za promenu lozinke na željenu email adresu</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Slanje..." class="w-full">
            Pošalji uputstva za promenu lozinke
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center mt-4">
        <.link href={~p"/nalog/novi"} class="dark:text-zinc-200 dark:hover:text-zinc-300">
          Novi nalog
        </.link>
        |
        <.link href={~p"/nalog/prijava"} class="dark:text-zinc-200 dark:hover:text-zinc-300">
          Prijava
        </.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = socket |> assign(:current_page, :user_auth)
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/nalog/nova_lozinka/#{&1}")
      )
    end

    info = "Ako postoji nalog sa unetom adresom, uputstva za promenu lozinke su poslata."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
