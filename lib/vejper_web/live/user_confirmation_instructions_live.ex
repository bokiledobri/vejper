defmodule VejperWeb.UserConfirmationInstructionsLive do
  use VejperWeb, :live_view

  alias Vejper.Accounts

  def render(assigns) do
    ~H"""
    <.header>Ponovo pošalji uputstva za promenu lozinke</.header>

    <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={@form[:email]} type="email" label="Email" required />
      <:actions>
        <.button phx-disable-with="Slanje...">Ponovo pošalji uputstva</.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/nalog/novi"}>Novi nalog</.link>
      | <.link href={~p"/nalog/prijava"}>Prijava</.link>
    </p>
    """
  end

  def mount(_params, _session, socket) do
    socket = socket |> assign(:current_page, :user_auth)
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/nalog/potvrda/#{&1}")
      )
    end

    info = "Ako postoji nalog sa unetom adresom, uputstva za promenu lozinke su poslata."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
