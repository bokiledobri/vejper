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
      live "/posts", PostLive.Index, :index

      live "/posts/show/:id", PostLive.Show, :show
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
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", VejperWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {VejperWeb.UserAuth, :ensure_authenticated},
        {VejperWeb.UserAuth, :mount_current_user}
      ] do
      live "/profiles/new", ProfileLive.Index, :new
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/users/settings", UserSettingsLive, :edit
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
      live "/profiles/edit", ProfileLive.Index, :edit

      live "/profiles/show/edit", ProfileLive.Show, :edit
      live "/posts/new", PostLive.Index, :new
      live "/posts/:id/edit", PostLive.Index, :edit
      live "/posts/show/:id/edit", PostLive.Show, :edit
      live "/chat", ChatLive.Index, :index
      live "/chat/new", ChatLive.Index, :new
      live "/chat/:id/edit", ChatLive.Index, :edit
      live "/chat/:id", ChatLive.Index, :show
    end
  end

  scope "/", VejperWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{VejperWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
      live "/profiles", ProfileLive.Index, :index
      live "/profiles/:id", ProfileLive.Show, :show
    end
  end
end
