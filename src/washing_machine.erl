%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jan 2020 16:43
%%%-------------------------------------------------------------------
-module(washing_machine).
-author("sebastian").

%% API
-export([init/1,calculate_progress/2]).


init({From, Capacity}) ->
  %io:fwrite("Washing machine started with capacity: ~w~n", [Capacity]),
  receive
    {From, {get_status}} ->
      From ! idle,
      init({From,Capacity});
    {From, {get_capacity}} ->
      From ! Capacity,
      init({From,Capacity});
    {From, {check_capacity,Weight}} ->
      Can_fit = check_capacity(Weight,Capacity),
      From ! Can_fit,
      init({From,Capacity});
    {From, {start,Weight,Program}} ->
      start_washing(From,Capacity,Program);
    {From, {get_needed_liquid_and_powder, Weight, Program}} ->
      From ! calculate_needed_resources(Weight, Program)
  end.


check_capacity(Weight,Capacity) ->
  if
    Weight > Capacity ->
      false;
    true ->
      true
  end.


work({From, Capacity, MaxTime, Time}) ->
  receive
    {From, {get_status}} ->
      From ! working,
      work({From,Capacity,MaxTime,Time});
    {From, {get_capacity}} ->
      From ! Capacity,
      work({From,Capacity,MaxTime,Time});
    {From, {get_time}} ->
      From ! Time,
      work({From,Capacity,MaxTime,Time});
    {From, {get_progress}} ->
      Progress = calculate_progress(MaxTime,Time),
      From ! Progress,
      work({From,Capacity,MaxTime,Time});
    {From, {stop}} ->
      init({From, Capacity})

    after 100 ->
      work({From,Capacity,MaxTime,Time - 0.1})
  end.


start_washing(From,Capacity,Program) ->
  Time = get_time(Program),
  work({From, Capacity, Time, Time}).


calculate_needed_resources(Weight, Program) ->
  {get_liquid(Program, Weight), get_powder(Program, Weight)}.


calculate_progress(Max_time,Time) ->
  (Max_time-Time)*100/Max_time.


get_cost(Program, Weight) ->
  CostPerKg = maps:get("CostPerKg", get_program(Program)),
  Weight * CostPerKg.


get_powder(Program, Weight) ->
  PowPerKg = maps:get("PowPerKg", get_program(Program)),
  Weight * PowPerKg.


get_liquid(Program, Weight) ->
  LiqPerKg = maps:get("LiqPerKg", get_program(Program)),
  Weight * LiqPerKg.


get_time(Program) ->
  maps:get("Time", get_program(Program)).


get_program(Program) ->
  maps:get(Program, get_programs()).


get_programs() ->
  #{
    1 => #{"PowPerKg" => 1, "LiqPerKg" => 1, "CostPerKg" => 1, "Time" => 60},
    2 => #{"PowPerKg" => 1.5, "LiqPerKg" => 2, "CostPerKg" => 2, "Time" => 60},
    3 => #{"PowPerKg" => 1.5, "LiqPerKg" => 1, "CostPerKg" => 1.5, "Time" => 70},
    4 => #{"PowPerKg" => 0.7, "LiqPerKg" => 0.7, "CostPerKg" => 1, "Time" => 30}}.