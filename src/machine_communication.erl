%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 14:06
%%%-------------------------------------------------------------------
-module(machine_communication).
-author("sebastian").

%% API
-export([machine_exists/1,can_machine_fit/2, get_machine_status/1, get_machine_needed_resources/3,
  get_machine_time/1, get_machine_progress/1, get_machine_capacity/1, stop_machine/1, start_machine/3]).

-import(resources, [get_machines/0]).


machine_exists(Id) ->
  Machines = get_machines(),
  Condition = (length(Machines) >= Id) and (Id > 0),
  if
    Condition  ->
      true;
    true ->
      false
  end.


get_machine_status(Id) ->
  send_command_to_machine_and_get_output(Id, {get_status}).


can_machine_fit(Id, Weight) ->
  send_command_to_machine_and_get_output(Id, {check_capacity, Weight}).


start_machine(Id, Weight, Program) ->
  send_command_to_machine(Id, {start,Weight,Program}).


get_machine_time(Id) ->
  send_command_to_machine_and_get_output(Id, {get_time}).


get_machine_needed_resources(Id, Weight, Program) ->
  send_command_to_machine_and_get_output(Id, {get_needed_resources, Weight, Program}).


get_machine_progress(Id) ->
  send_command_to_machine_and_get_output(Id, {get_progress}).


get_machine_capacity(Id) ->
  send_command_to_machine_and_get_output(Id, {get_capacity}).


stop_machine(Id) ->
  send_command_to_machine(Id, {stop}).


send_command_to_machine(Id, Command) ->
  Machines = get_machines(),
  Pid = lists:nth(Id,Machines),
  Pid ! {self(), Command}.


send_command_to_machine_and_get_output(Id, Command) ->
  send_command_to_machine(Id, Command),
  get_inbox().


get_inbox() -> receive X -> X end.