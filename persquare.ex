defmodule PerfectSquareFinder do
  @moduledoc """
  This module acts as a server for finding perfect squares.
  """

  @doc """
  1. Initially sends a ready message to the scheduler to indicate that it is idle and ready to do a task
  2. Waits for a message from the scheduler:
    * If {:perfect, range, client}, sends the result returned from is_perfect_square to the scheduler. Makes a tail recursive call to itself so that the process stays alive.
    * If {:shutdown}, the process dies

  ## Parameters
  - scheduler: Master pid which handles and mananges all the processes
  """

  def perfect_square_manager(scheduler) do
    send(scheduler, {:ready, self()})

    receive do
      {:perfect, range, client} ->
        res = is_perfect_square(range)
        list = Enum.to_list(range)
        send(client, {res, List.first(list), self()})
        perfect_square_manager(scheduler)

      {:shutdown} ->
        exit(:normal)
    end
  end

  @doc """
  * returns true if the sum of squares of all the numbers in the given range is a perfect square.
  * returns false otherwise

  ## Parameters
  - range: sequence of length k
  """
  def is_perfect_square(range) do
    sum = Enum.map(range, fn x -> x * x end) |> Enum.sum()
    :math.sqrt(sum) |> :erlang.trunc() |> :math.pow(2) |> :erlang.trunc() == sum
  end
end

defmodule Scheduler do
  @moduledoc """
  Acts as a master process which spawns and manages all the processes.
  """

  @doc """
  Spawns a specified number of processes and feeds their pid's to master_scheduler/4.

  ## Parameters
  - n: First command line argument
  - module: The module to which processes are spawned
  - func: The function to be called under module
  - k: Second command line argument
  """

  def run(n, module, func, k) do
    # calls no_of_processes/1
    num = no_of_processes(n)
    # spawns specified number of processes
    1..num |> Enum.map(fn _ -> spawn(module, func, [self()]) end)
    # calls master_scheduler/4 where 1st argument comes through pipe
    |> master_scheduler(n, k, [],num)
  end

  @doc """
  returns number of processes to be spawned based on n
  ## Parameters
  - n: First command line argument
  """
  def no_of_processes(n) do
    if n > 1000 do
      1000
    else
      n
    end
  end
    
  @doc """
  Handles job assignment and manages the spawned processes.

  ## Parameters
  - processes: List of pid's of spawned processes
  - n: First command line argument
  - k: Second command line argument
  - results: List of first number in the perfect square sequences. Initially it is empty
  - num: number of processes spawned
  """
  def master_scheduler(processes, n, k, results, num) do
    receive do
      # this case matches when a process is ready to perform a task and the tasks are available
      {:ready, pid} when n > 0 ->
        # sends a sequence to the process pid
        send(pid, {:perfect, n..(n + k - 1), self()})
        # performs tail recursion so that the master process doesn't die
        master_scheduler(processes, n - 1, k, results, num)

      # this case matches when a process is ready to perform a task and the tasks are not available
      {:ready, pid} ->
        # signals the process to kill itself as no tasks are available
        send(pid, {:shutdown})

        if num > 1 do
          # Performs tail recursion as there are processes still alive which need to be handled
          master_scheduler(processes, n, k, results, num-1)
        else
          # prints the final result as all the processes have finished their tasks and dead
          results
        end

      # this case matches when a process sends a message saying that the sequence it received, is a perfect sqaure sequence
      {true, first, _pid} ->
        # appends the first number in the sequence to the results list and performs tail recursion
        master_scheduler(processes, n, k, [first | results], num)

      # this case matches when a process sends a message saying the sequence it received is not a perfect sqaure sequence
      {false, _, _pid} ->
        # performs tail recursion
        master_scheduler(processes, n, k, results, num)
    end
  end
end


defmodule MainModule do
  @moduledoc """
  Acts as the main module
  """

  @doc """
  Main method which parses command line arguments and calls the scheduler.
  """
  def main() do
    # collecting command line arguments
    arguments = System.argv()

    # converting command line args from string to integer
    first_arg_tuple = Integer.parse(List.first(arguments))
    second_arg_tuple = Integer.parse(List.last(arguments))

    # checking if the command line arguments are in the right format
    if first_arg_tuple == :error do
      IO.puts("N should be an integer")
      exit(:shutdown)
    end

    if second_arg_tuple == :error do
      IO.puts("k should be an integer")
      exit(:shutdown)
    end

    # assigning arguments to N and k
    {n, _} = first_arg_tuple
    {k, _} = second_arg_tuple

    # calling the master_scheduler/1 module which is our master process
    result = Scheduler.run(n, PerfectSquareFinder, :perfect_square_manager, k)

    # printint the final result list in sorted order by disabling char list printing
    IO.inspect Enum.sort(result), charlists: :as_lists
  end
end

# Calling the main method inside MainModule
MainModule.main()