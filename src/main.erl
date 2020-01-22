%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jan 2020 17:49
%%%-------------------------------------------------------------------
-module(main).
-author("sebastian").

%% API
-export([main/0, create_washing_machines/1, machine_exists/1]).
-import(mochinum, [digits/1]).
-import(washing_machine,[init/1]).
-import(command_managerr,[command/1,read_number/1]).


main() ->
  Machines = create_washing_machines([5, 6, 7, 8]),
  Starting_washing_liquid = 100,
  Starting_washing_powder = 100,
  Starting_money = 100,
  ets:new(laundry, [named_table, public, set]),
  ets:insert(laundry, {machines, Machines}),
  ets:insert(laundry, {washing_liquid, Starting_washing_liquid}),
  ets:insert(laundry, {washing_powder, Starting_washing_powder}),
  ets:insert(laundry, {money, Starting_money}),
  timer:sleep(500),
  main_loop().


create_washing_machines(ToCreate) ->
  create_washing_machines(ToCreate, []).


create_washing_machines([], Created) ->
  Created;


create_washing_machines([Next | To_create], Created) ->
  New_machine = spawn(washing_machine, init, [{self(), Next}]),
  create_washing_machines(To_create, Created ++ [New_machine]).


main_loop() ->
  Command = command_managerr:command(read_action),
  execute_command(Command),
  %show_machines(Machines),
  %start_washing(Machines),
  main_loop().


execute_command(Command) ->
  case Command of
    l ->
      show_machines();
    s ->
      start_washing();
    p ->
      view_progress();
    t ->
       terminate_washing()
  end.


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
  if
    Viewing_time < 0 ->
      ok;
    Time > 0.5 ->
      timer:sleep(500),
      view_washing_progress(Id,Viewing_time-0.5);
    true ->
      ok
  end.


create_progress_bar(Progress) ->
  N = round(Progress/5),
  io:fwrite("Progress: |~ts|%~n", [lists:duplicate(N, "█") ++ lists:duplicate(20-N, "-")]).


start_washing() ->
  {Id,Weight,Program} = command_managerr:command(start_washing),

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
      io_lib:format("~.1f zl was paid", [Price]),
      view_washing_progress(Id,5);
    true ->
      io:fwrite("There is not enough liquid or powder! Try again later~n")
  end.


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


add_money(Amount) ->
  OldMoney = get_money(),
  NewMoney = OldMoney + Amount,
  ets:delete(laundry, money),
  ets:insert(laundry, {money, NewMoney}).


use_liquid(Weight) ->
  OldLiquid = get_liquid(),
  NewLiquid = OldLiquid - Weight,
  ets:delete(laundry, washing_liquid),
  ets:insert(laundry, {washing_liquid, NewLiquid}).


use_powder(Weight) ->
  OldPowder = get_powder(),
  NewPowder = OldPowder - Weight,
  ets:delete(laundry, washing_powder),
  ets:insert(laundry, {washing_powder, NewPowder}).


get_powder() ->
  [{washing_powder, Powder}] = ets:lookup(laundry, washing_powder),
  Powder.


get_liquid() ->
  [{washing_liquid, Liquid}] = ets:lookup(laundry, washing_liquid),
  Liquid.


get_money() ->
  [{money, Money}] = ets:lookup(laundry, money),
  Money.


get_machines() ->
  [{machines, Machines}] = ets:lookup(laundry, machines),
  Machines.
