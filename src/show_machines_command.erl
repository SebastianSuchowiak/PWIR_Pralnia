%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 15:04
%%%-------------------------------------------------------------------
-module(show_machines_command).
-author("sebastian").

%% API
-export([show_machines/0]).

-import(machine_communication, [get_machine_status/1, get_machine_capacity/1, machine_exists/1]).


show_machines() ->
  get_machines_statuses(1).


get_machines_statuses(N) ->
  Status = get_machine_status(N),
  Capacity = get_machine_capacity(N),
  io:fwrite("Washing Machine ~w Capacity ~w Status: ~w~n", [N, Capacity, Status]),

  Is_this_last_machine = machine_exists(N+1) == false,
  if
    Is_this_last_machine -> ok;
    true -> get_machines_statuses(N + 1)
  end.