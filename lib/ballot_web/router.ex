defmodule BallotWeb.Router do
  use BallotWeb, :router

  import BallotWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BallotWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BallotWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  if Application.compile_env(:ballot, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BallotWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", BallotWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BallotWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", RegisterLive, :new
      live "/login", LoginLive, :new
      live "/reset-password", ForgotPasswordLive, :new
      live "/reset-password/:token", ResetPasswordLive, :edit
    end

    post "/login", UserSessionController, :create
  end

  scope "/", BallotWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BallotWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", SettingsLive, :edit
      live "/settings/confirm_email/:token", SettingsLive, :confirm_email
    end
  end

  scope "/", BallotWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{BallotWeb.UserAuth, :mount_current_user}] do
      live "/confirm/:token", ConfirmationLive, :edit
      live "/confirm", ConfirmationInstructionsLive, :new
    end
  end
end
