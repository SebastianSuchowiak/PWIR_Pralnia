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

-import(main, [create_washing_machines/1, machine_exists/1]).
-include_lib("eunit/include/eunit.hrl").

test_machine_exists_test_() ->
  Machines = main:create_washing_machines([5, 6, 7, 8]),
  ets:new(test, [named_table, public, set]),
  ets:insert(test, {machines, Machines}),
  [?_assertEqual(true, main:machine_exists(1)),
    ?_assertEqual(false, main:machine_exists(-2)),
    ?_assertEqual(false, main:machine_exists(0)),
    ?_assertEqual(false,main:machine_exists(5))].

