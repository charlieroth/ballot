defmodule Ballot do
  @moduledoc false

  def get_datacenter do
    [datacenter, _availability_zone, _node] =
      Node.self()
      |> Atom.to_string()
      |> String.split("@")
      |> Enum.at(0)
      |> String.split("_")

    datacenter
  end
end
