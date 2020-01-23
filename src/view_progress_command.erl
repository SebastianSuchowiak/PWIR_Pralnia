%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 14:52
%%%-------------------------------------------------------------------
-module(view_progress_command).
-author("sebastian").

%% API
-export([view_progress/0, view_washing_progress/2]).
-import(machine_communication, [machine_exists/1, get_machine_status/1, get_machine_progress/1, get_machine_time/1]).
-import(print_washing_machine, [print_animation/0]).


view_progress() ->
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
      view_washing_progress(Id,5);
    true ->
      io:fwrite("This machine is Idle~n")
  end.


view_washing_progress(Id,Viewing_time) ->
  Time = get_machine_time(Id),
  Progress = get_machine_progress(Id),
  io:format("\ec"),
  io:fwrite("Time Left:~w~n",[math:floor(Time)]),
  create_progress_bar(Progress),
  print_animation(),
  if
    Viewing_time < 0 ->
      ok;
    Time > 0.150 ->
      timer:sleep(150),
      view_washing_progress(Id,Viewing_time-0.150);
    true ->
      ok
  end,
  io:format("\ec").


create_progress_bar(Progress) ->
  N = round(Progress/5),
  io:fwrite("Progress: |~ts|%~n", [lists:duplicate(N, "█") ++ lists:duplicate(20-N, "-")]).