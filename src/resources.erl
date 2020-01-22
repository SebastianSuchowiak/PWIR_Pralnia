%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 14:08
%%%-------------------------------------------------------------------
-module(resources).
-author("sebastian").

%% API
-export([add_money/1, use_liquid/1, use_powder/1, get_powder/0, get_liquid/0, get_money/0, get_machines/0]).

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