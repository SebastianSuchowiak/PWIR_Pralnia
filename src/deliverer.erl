%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 13:38
%%%-------------------------------------------------------------------
-module(deliverer).

-export([start/1]).

start({From,Max_powder,Max_liquid}) ->
  receive
  after 6000 ->
    buy_items(Max_powder,Max_liquid),
    start({From,Max_powder,Max_liquid})
  end.


buy_items(Max_powder,Max_liquid) ->
  Current_liquid = get_liquid(),
  Current_powder = get_powder(),
  Needed_powder = resource_needed_quantity(Max_powder,Current_powder),
  Needed_liquid = resource_needed_quantity(Max_liquid,Current_liquid),
  if
    Needed_liquid == 0 ->
      ok;
    true ->
      buy(Needed_liquid,1,washing_liquid)
  end,
  if
    Needed_powder == 0 ->
      ok;
    true ->
      buy(Needed_powder,1,washing_powder)
  end.


resource_needed_quantity(Max,Current) ->
  Current_percent = Current*100/Max,
  if
    Current_percent > 70 ->
      0;
    Current_percent > 50 ->
      Max*0.3;
    Current_percent > 20 ->
      Max*0.5;
    true ->
      Max*0.8
  end.


buy(Quantity,Price,Item_type) ->
  Total_price = Quantity * Price,
  [{Item_type, Current_quantity}] = ets:lookup(laundry, Item_type),
  ets:delete(laundry, Item_type),
  ets:insert(laundry, {Item_type, Current_quantity +Quantity }),
  subtract_cash(Total_price).


subtract_cash(Amount) ->
  [{money, Current_money}] = ets:lookup(laundry, money),
  ets:delete(laundry, money),
  ets:insert(laundry, {money, Current_money - Amount}).


get_powder() ->
  [{washing_powder, Powder}] = ets:lookup(laundry, washing_powder),
  Powder.


get_liquid() ->
  [{washing_liquid, Liquid}] = ets:lookup(laundry, washing_liquid),
  Liquid.
