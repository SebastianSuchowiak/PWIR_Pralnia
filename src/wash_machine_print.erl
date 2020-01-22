%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jan 2020 03:25
%%%-------------------------------------------------------------------
-module(wash_machine_print).
-author("sebastian").

%% API
-export([print_animation/3, get_data/0]).

main() ->
  Data = read_file().


print_animation(Data,_,8) ->
  print_animation(Data,1+1,1).


get_data() ->
  ok.

get_iteration() ->
  ok.


print_animation(Data,Start,Iteration) ->
  Length = 61*36,
  io:fwrite("~ts",[lists:sublist(Data,Start,Length)]),
  {Start+Length+1,Iteration}.
  %print_animation(Data,Start+Length+1,Iteration+1).


get_all_lines(Device) ->
  case io:get_line(Device, "") of
    eof  -> [];
    Line -> Line ++ get_all_lines(Device)
  end.


read_file() ->
  {ok, File} = file:open("machine_ascii.txt",[read]),
  try get_all_lines(File)
  after file:close(File)
  end.