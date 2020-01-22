%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 14:56
%%%-------------------------------------------------------------------
-module(start_washing_command).
-author("sebastian").

%% API
-export([start_washing/0]).

-import(view_progress_command, [view_washing_progress/2]).
-import(machine_communication, [machine_exists/1, get_machine_status/1, get_machine_capacity/1,
get_machine_needed_resources/3, can_machine_fit/2,start_machine/3]).
-import(resources, [get_liquid/0, get_powder/0, get_money/0, use_liquid/1, use_powder/1, add_money/1]).


start_washing() ->
  {Id,Weight,Program} = command_managerr:command(start_washing),

  Machine_exist = machine_exists(Id),
  if
    Machine_exist == true ->
      ok;
    true ->
      io:fwrite("Machine with this ID doesn't exist~n"),
      start_washing()
  end,

  Status = get_machine_status(Id),
  if
    Status == working ->
      io:fwrite("Select another Washing Mashine, this one is already working~n"),
      start_washing();
    true ->
      ok
  end,

  Can_fit = can_machine_fit(Id, Weight),
  if
    Can_fit == false ->
      io:fwrite("Too much laundry! Weight is too big~n"),
      start_washing();
    true ->
      ok
  end,

  {Needed_liquid, Needed_powder, Price} = get_machine_needed_resources(Id, Weight, Program),
  Resources_are_available = (get_liquid() >= Needed_liquid) and (get_powder() >= Needed_powder),
  if
    Resources_are_available ->
      use_liquid(Needed_liquid),
      use_powder(Needed_powder),
      add_money(Price),
      start_machine(Id, Weight, Program),
      Price_string = float_to_list(Price, [{decimals,0}]),
      io:fwrite("Charged ~s zl~n", [Price_string]),
      timer:sleep(800),
      view_washing_progress(Id,5);
    true ->
      io:fwrite("There is not enough liquid or powder! Try again later~n")
  end.