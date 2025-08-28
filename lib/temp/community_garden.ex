defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  @moduledoc """
  A simple registry for community garden plot registrations using Agent.
  
  Agent is a simple abstraction around state management in Elixir processes.
  It provides a straightforward way to maintain state but has limitations:
  - No built-in error handling or recovery mechanisms
  - Limited to simple state operations
  - Not suitable for complex business logic or workflows
  - Cannot run asynchronous queries or computations in the server process
  
  For more complex scenarios, consider using GenServer instead.
  """
  def start(opts \\ []) do
    # extract options now (in case you add filtering in the future)
    _opts = Keyword.merge([filter: nil], opts)

    {:ok, pid} = Agent.start(fn -> {[], 1} end)
    {:ok, pid}
  end

  def list_registrations(pid) do
    Agent.get(pid, fn {plots, _next_id} -> plots end)
  end

  def register(pid, register_to) do
    Agent.get_and_update(pid, fn {plots, next_id} ->
      plot = %Plot{plot_id: next_id, registered_to: register_to}
      {plot, {[plot | plots], next_id + 1}}
    end)
  end

  def release(pid, plot_id) do
    Agent.update(pid, fn {plots, next_id} ->
      {Enum.reject(plots, fn plot -> plot.plot_id == plot_id end), next_id}
    end)
    :ok
  end

  def get_registration(pid, plot_id) do
    Agent.get(pid, fn {plots, _next_id} ->
      case Enum.find(plots, fn plot -> plot.plot_id == plot_id end) do
        nil -> {:not_found, "plot is unregistered"}
        plot -> plot
      end
    end)
  end
end
