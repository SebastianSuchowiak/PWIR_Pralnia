%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jan 2020 20:02
%%%-------------------------------------------------------------------

-module(command_manager_test).
-author("sebastian").

-import(command_managerr, [is_numeric/1, validate_action/1]).

-include_lib("eunit/include/eunit.hrl").

test_fun_test_() ->
  [?_assertEqual(true, command_managerr:is_numeric("123")),
    ?_assertEqual(false, command_managerr:is_numeric("")),
    ?_assertEqual(false, command_managerr:is_numeric("12.3")),
    ?_assertEqual(false, command_managerr:is_numeric("12bs"))].

test_validate_action_test_() ->
  [?_assertEqual(true, command_managerr:validate_action(s)),
    ?_assertEqual(true, command_managerr:validate_action(t)),
    ?_assertEqual(true, command_managerr:validate_action(l)),
    ?_assertEqual(true, command_managerr:validate_action(p)),
    ?_assertEqual(true, command_managerr:validate_action(r)),
    ?_assertEqual(false, command_managerr:validate_action(p1)),
    ?_assertEqual(false, command_managerr:validate_action(a))].