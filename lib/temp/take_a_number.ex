defmodule TakeANumber do
  @moduledoc """
  A simple take-a-number machine implementation using Elixir processes.

  The machine can give out consecutive numbers and report the last number given out.
  It runs as a separate process and communicates via message passing.
  """

  @doc """
  Starts a new take-a-number machine process.

  Returns the PID of the spawned process which maintains the machine's state
  and handles incoming messages.

  ## Examples

      iex> pid = TakeANumber.start()
      iex> is_pid(pid)
      true

  ## Messages

  The spawned process handles these messages:
  - `{:report_state, sender_pid}` - Reports current state to sender
  - `{:take_a_number, sender_pid}` - Issues next number and sends to sender
  - `:stop` - Stops the machine process
  - Any other message is ignored
  """
  @spec start() :: pid()
  def start() do
    spawn(fn -> loop(0) end)
  end

  @spec loop(non_neg_integer()) :: nil
  defp loop(state) do
    receive do
      # Pattern matches the expected message format
      {:report_state, sender_pid} ->
        # Sends current state back to the requester
        send(sender_pid, state)
        # Recursively calls itself to wait for more messages
        loop(state)
      {:take_a_number, sender_pid} ->
        next_number = state + 1  # next_number = 1, considering first increment
        send(sender_pid, next_number)
        loop(next_number)        # NEW function call with state = 1, considering first increment
      :stop ->
        :ok
      _unknown_message ->
        loop(state)
    end
  end
end
