import Config

case config_env() do
  :dev -> Code.require_file("runtime.dev.exs", "config")
  :test -> Code.require_file("runtime.test.exs", "config")
  :prod -> Code.require_file("runtime.prod.exs", "config")
end
