%%%-------------------------------------------------------------------
%%% @author sebastian
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jan 2020 19:48
%%%-------------------------------------------------------------------
-module(command_managerr).
-author("sebastian").

%% API
-import(re, [run/2]).

-export([command/1, is_numeric/1,validate_action/1,read_number/1]).

command(Action) ->
  case Action of
    start_washing ->
      Result = read_starting_data();
    read_action ->
      Result = get_action()
  end,
  Result.


read_starting_data() ->
  Id = read_number("Enter Washing Machine Id: "),
  Weight = read_number("Enter Laundry Weight: "),
  Program = read_number("Enter desired Program: "),
  {Id,Weight,Program}.

read_number(Message) ->
  {Read_status, Number} = io:read(Message),

  if
    Read_status == ok -> Number_is_valid = is_number(Number);
    true -> Number_is_valid = false
  end,

  if
    Number_is_valid -> Number;
    true -> io:fwrite("Value is not a number~n"),
      read_number(Message)
  end.

is_numeric(String) ->
  Regex_result = re:run(String, "^[0-9]+$"),
  if
    Regex_result == nomatch -> false;
    true -> true
  end.

get_action() ->
  print_actions(),
  read_action().

print_actions() ->
  io:fwrite("Press s to start washing~n"),
  io:fwrite("Press l to list washing machines~n"),
  io:fwrite("Press p to view progress of selected machine~n"),
  io:fwrite("Press t to terminate washing process ~n").


read_action() ->
  {Read_status, Action} = io:read(""),
  Action_is_valid = validate_action(Action),
  if
    Action_is_valid == true ->
      Action;
    true ->
      io:fwrite("Command is not valid~n"),
      read_action()
  end.

validate_action(Action) ->
  Possible_actions = [s,l,p,t],
  lists:member(Action,Possible_actions).
