%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 04:19
%%%-------------------------------------------------------------------
-module(print_washing_machine).
-author("sebastian").

%% API
-export([prepare_animation/0, print_animation/0]).


prepare_animation() ->
  Data = read_file(),
  ets:new(animation, [named_table, private, set]),
  ets:insert(animation, {data, Data}),
  ets:insert(animation, {iteration, 1}).


print_animation() ->
  Iteration = get_iteration(),
  print_animation(Iteration),
  iteration_forward().


print_animation(Iteration) ->
  Data = get_data(),
  Length = 61*36,
  io:fwrite("~ts",[lists:sublist(Data,(Iteration-1)*Length+Iteration,Length)]).


get_data() ->
  [{data, Data}] = ets:lookup(animation, data),
  Data.


get_iteration() ->
  [{iteration, Iteration}] = ets:lookup(animation, iteration),
  Iteration.


iteration_forward() ->
  Old_iteration = get_iteration(),
  if
    Old_iteration + 1 > 8 ->  New_iteration = 1;
    true -> New_iteration = Old_iteration + 1
  end,
  ets:delete(animation, iteration),
  ets:insert(animation, {iteration, New_iteration}).


get_all_lines(Device) ->
  case io:get_line(Device, "") of
    eof  -> [];
    Line -> Line ++ get_all_lines(Device)
  end.


read_file() ->
  {ok, File} = file:open("res/machine_ascii.txt",[read]),
  try get_all_lines(File)
  after file:close(File)
  end.