%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 15:01
%%%-------------------------------------------------------------------
-module(show_resources_command).
-author("sebastian").

%% API
-export([show_resources/0]).

-import(resources, [get_money/0, get_powder/0, get_liquid/0]).

show_resources() ->
  Money = float_to_list(get_money(), [{decimals,2}]),
  Powder = float_to_list(get_powder(), [{decimals,2}]),
  Liquid = float_to_list(get_liquid(), [{decimals,2}]),
  io:fwrite("Money: ~s~nPowder: ~s~nLiquid: ~s~n", [Money, Powder, Liquid]).