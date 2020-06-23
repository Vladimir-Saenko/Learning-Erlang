%%%-------------------------------------------------------------------
%%% @author Владимир 'siborg' Саенко
%%% @doc
%%% Задачки от Revent-а, чтобы сломать мозг и бросить учить Erlang
%%% На входе: строка с выражениями в скобках.
%%% Задача: Убрать скобки из строки, реверсируя их содежимое
%%% @end
%%% Created : 24. май 2020 22:27
%%%-------------------------------------------------------------------
-module(task_1).
-author("Владимир 'siborg' Саенко").

%% API
-export([task1_start/1, task11_start/1, find_open/1]).

%% Вариант №1 Тупо в лоб
%% ===========================================================

task1_start(Str) ->
  Brackets_Pos=search_brackets(Str),            % Определяем позиции наиболее глубоко
  case Brackets_Pos of                          % вложенных скобок
    {ok, Begin_Pos, End_Pos} ->
      Str1=rev_rem(Str, Begin_Pos, End_Pos),    % реверсируем содержимое и убираем скобки
      task1_start(Str1);                        % ищем следующую пару скобок
    _Any -> Str
  end.

search_brackets(Str) ->
  End_Pos=scan_str_r(Str, 1),
  if
    End_Pos > 0 andalso End_Pos =< length(Str) ->
      Begin_Pos=scan_str_l(Str, End_Pos - 1),
      if
        Begin_Pos > 0 ->
          {ok, Begin_Pos, End_Pos};
        true -> {no_brackets}
      end;
    true -> {no_brackets}
  end.

scan_str_r(Str, Pos) when Pos =< length(Str) ->   % Ищем первую закрывающуюся скобку
  case lists:nth(Pos, Str) of
    41 -> Pos;
    _ -> scan_str_r(Str, Pos + 1)
  end;
scan_str_r(_Str, _Pos) -> 0.

scan_str_l(Str, Pos) when Pos > 0 ->              % Ищем парную открывающуюся скобку
  case lists:nth(Pos, Str) of
    40 -> Pos;
    _ -> scan_str_l(Str, Pos - 1)
  end;
scan_str_l(_Str, _Pos) -> 0.

rev_rem(Str, Begin_Pos, End_Pos) ->               % берем содержимое скобок, реверсируем
  SubStr=lists:reverse(lists:sublist(Str, Begin_Pos + 1, End_Pos - Begin_Pos - 1)),
  Str_Begin=lists:sublist(Str, Begin_Pos - 1),
  Str_End=lists:sublist(Str, End_Pos + 1, length(Str) - End_Pos),
  Str_Begin ++ SubStr ++ Str_End.                 % Склеиваем строку

%% Вариант №2 Через свертку
%% =======================

task11_start(Str) ->
  F = fun(X, Acc) ->                      % Функция для свертки
    if X =/= 41 -> [X | Acc];             % Если не закрывающая скобка, то кидаем в аккумулятор
      true -> cut_par(Acc, "")           % иначе убираем парную открывающую скобку
    end end,
  lists:reverse(lists:foldl(F, "", Str)). % свертка и реверс выходного списка

cut_par([H | T], Acc) when H =/= 40 ->    % Если в голове не открывающая скобка
  cut_par(T, [H | Acc]);                  % то кидаем в аккумулятор и рекурсируем хвост
cut_par([_H | T], Acc) -> Acc ++ T;       % если скобка, то склеиваем аккумулятор и хвост
cut_par([], Acc) -> Acc.                  % возврат аккумулятора, когда список кончился

%% Вариант Revent-а через splitwith
%% ================================

find_open(Str) ->
  case lists:splitwith(fun(X) -> X =/= $( end, Str) of
    {Str, []} -> find_close(Str);
    {NewStr, [$( | Rest]} ->
      find_open(lists:append(NewStr, find_open(Rest)))
  end.

find_close(Str) ->
  case lists:splitwith(fun(X) -> X =/= $) end, Str) of
    {Str, []} -> Str;
    {NewStr, [$) | Rest]} ->
      lists:append(lists:reverse(NewStr), Rest)
  end.