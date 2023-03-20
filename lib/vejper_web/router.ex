defmodule VejperWeb.Router do
  use VejperWeb, :router

  import VejperWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {VejperWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VejperWeb do
    pipe_through :browser

    live_session :mount_current_user,
      on_mount: {VejperWeb.UserAuth, :mount_current_user} do
      live "/objave", PostLive.Index, :index
      live "/objava/:id", PostLive.Show, :show

      live "/oglasi", AdLive.Index, :index
      live "/oglas/:id", AdLive.Show, :show
      get "/", PageController, :home
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", VejperWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vejper, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VejperWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", VejperWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{VejperWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/nalog/novi", UserRegistrationLive, :new
      live "/nalog/prijava", UserLoginLive, :new
      live "/nalog/nova_lozinka", UserForgotPasswordLive, :new
      live "/nalog/nova_lozinka/:token", UserResetPasswordLive, :edit
    end

    post "/nalog/prijava", UserSessionController, :create
  end

  scope "/", VejperWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {VejperWeb.UserAuth, :ensure_authenticated},
        {VejperWeb.UserAuth, :mount_current_user}
      ] do
      live "/profili/novi", ProfileLive.Index, :new
      live "/nalog/podesavanja/potvrda_adrese/:token", UserSettingsLive, :confirm_email
      live "/nalog/podesavanja", UserSettingsLive, :edit
    end
  end

  scope "/", VejperWeb do
    pipe_through [:browser, :require_authenticated_user, :require_user_profile]

    live_session :require_user_profile,
      on_mount: [
        {VejperWeb.UserAuth, :ensure_authenticated},
        {VejperWeb.UserAuth, :mount_current_user},
        {VejperWeb.UserAuth, :ensure_profile_completed}
      ] do
      live "/profil/uredi", ProfileLive.Show, :edit
      live "/objave/nova", PostLive.Index, :new
      #      live "/posts/:id/edit", PostLive.Index, :edit
      #      live "/posts/show/:id/edit", PostLive.Show, :edit
      live "/caskanje", ChatLive.Index, :index
      live "/caskanje/nova_soba", ChatLive.Index, :new
      live "/caskanje/sobe/:id/uredi", ChatLive.Index, :edit
      live "/caskanje/:id", ChatLive.Index, :show
      live "/oglasi/novi", AdLive.Index, :new
      live "/oglas/:id/uredi", AdLive.Show, :edit
    end
  end

  scope "/admin", VejperWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_session :require_user_admin,
      on_mount: [
        {VejperWeb.UserAuth, :ensure_authenticated},
        {VejperWeb.UserAuth, :mount_current_user},
        {VejperWeb.UserAuth, :ensure_admin}
      ] do
      live "/", AdminLive.Index, :index
    end
  end

  scope "/", VejperWeb do
    pipe_through [:browser]

    delete "/nalog/odjava", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{VejperWeb.UserAuth, :mount_current_user}] do
      live "/nalog/potvrda/:token", UserConfirmationLive, :edit
      live "/nalog/potvrda/", UserConfirmationInstructionsLive, :new
      live "/profili", ProfileLive.Index, :index
      live "/profil/:id", ProfileLive.Show, :show
    end
  end
end
