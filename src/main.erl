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
-export([main/0]).
-import(washing_machinee,[init/1]).
-import(deliverer, [start/1]).
-import(print_washing_machine, [prepare_animation/0]).
-import(command_managerr,[command/1]).
-import(show_machines_command, [show_machines/0]).
-import(show_resources_command, [show_resources/0]).
-import(start_washing_command, [start_washing/0]).
-import(view_progress_command, [view_progress/0]).
-import(terminate_washing_command, [terminate_washing/0]).


main() ->
  init_resources(),
  prepare_animation(),
  start_deliverer(),
  timer:sleep(500),
  main_loop().


main_loop() ->
  Command = command_managerr:command(read_action),
  execute_command(Command),
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
      terminate_washing();
    r ->
      show_resources()
  end.


start_deliverer() ->
  spawn(deliverer, start, [{self(), 200.0, 200}]).


init_resources() ->
  ets:new(laundry, [named_table, public, set]),

  Machines = create_washing_machines([5, 6, 7, 8]),
  ets:insert(laundry, {machines, Machines}),

  Starting_washing_liquid = 1000.0,
  Starting_washing_powder = 100.0,
  Starting_money = 100.0,
  ets:insert(laundry, {machines, Machines}),
  ets:insert(laundry, {washing_liquid, Starting_washing_liquid}),
  ets:insert(laundry, {washing_powder, Starting_washing_powder}),
  ets:insert(laundry, {money, Starting_money}).


create_washing_machines(ToCreate) ->
  create_washing_machines(ToCreate, []).


create_washing_machines([], Created) ->
  Created;


create_washing_machines([Next | To_create], Created) ->
  New_machine = spawn(washing_machinee, init, [{self(), Next}]),
  create_washing_machines(To_create, Created ++ [New_machine]).
