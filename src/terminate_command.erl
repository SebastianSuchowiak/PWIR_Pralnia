%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 14:05
%%%-------------------------------------------------------------------
-module(terminate_command).
-author("sebastian").

%% API
-export([terminate_washing/0]).


terminate_washing() ->
  Id = command_managerr:read_number("Enter Washing Machine ID: "),

  Machine_exist = machine_exists(Id),
  if
    Machine_exist == true ->
      ok;
    true ->
      io:fwrite("Machine with this ID doesn't exist~n"),
      view_progress()
  end,

  Status = get_machine_status(Id),
  if
    Status == working ->
      stop_machine(Id),
      io:fwrite("Machine sotoped~n");
    true ->
      io:fwrite("This machine is Idle~n")
  end.