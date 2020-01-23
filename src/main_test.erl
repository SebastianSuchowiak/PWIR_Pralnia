%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jan 2020 16:04
%%%-------------------------------------------------------------------
-module(main_test).
-author("sebastian").

-include_lib("eunit/include/eunit.hrl").

test_machine_exists_test_() ->
  Machines = main:create_washing_machines([5, 6, 7, 8]),
  ets:new(laundry, [named_table, public, set]),
  ets:insert(laundry, {machines, Machines}),
  [?_assert(machine_communication:machine_exists(1)),
    ?_assert(machine_communication:machine_exists(0)),
    ?_assert(machine_communication:machine_exists(1)),
    ?_assert(machine_communication:machine_exists(1)),
    ?_assert(machine_communication:machine_exists(1))].


