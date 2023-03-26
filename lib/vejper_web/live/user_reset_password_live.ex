defmodule VejperWeb.UserResetPasswordLive do
  use VejperWeb, :live_view

  alias Vejper.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Promena lozinke</.header>

      <.simple_form
        for={@form}
        id="reset_password_form"
        phx-submit="reset_password"
        phx-change="validate"
      >
        <.input field={@form[:password]} type="password" label="Nova lozinka" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Potvrda nove lozinke"
          required
        />
        <:actions>
          <.button phx-disable-with="Promena u toku..." class="w-full">Promeni lozinku</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/nalog/novi"}>Novi nalog</.link>
        | <.link href={~p"/nalog/prijava"}>Prijava</.link>
      </p>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket =
      assign_user_and_token(socket, params)
      |> assign(:current_page, :user_auth)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lozinka uspešno promenjena")
         |> redirect(to: ~p"/nalog/prijava")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Link za promenu lozinke nije validan ili je zastareo")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
