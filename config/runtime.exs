import Config
import Logger

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  level: :info
