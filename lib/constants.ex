defmodule Typit.Constants do
  def time_limit, do: 5_000
  def setup, do: "#import \"@preview/catppuccin:1.0.0\": catppuccin, flavors;#show: catppuccin.with(flavors.mocha);#set page(height: auto, width: auto, margin: 28pt);#set text(size: 44pt);"
end
