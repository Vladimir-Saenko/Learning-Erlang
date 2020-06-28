%%%-------------------------------------------------------------------
%%% @author Владимир 'siborg' Саенко
%%% @doc
%%% Задачки от Revent-а, чтобы сломать мозг и бросить учить Erlang
%%% ==================================================================
%%% Задача №3
%%% На входе: Бинарная строка типа  <<"ABC Def ghi">> и номер слова
%%% Задача: вывод слова с заданным порядковым номером. (Кодировка utf-8)
%%% Статус - Revent остался недоволен всеми вариантами ))
%%% @end
%%% Created : 01 июнь 2020 11:20
%%%-------------------------------------------------------------------
-module(task_3).
-author("Владимир 'siborg' Саенко").

%% API
-export([start1/2, start2/2, start3/2, start4/2]).

%% Вариант №1
%% ==========
start1(BinStr, Num) ->
  lists:nth(Num,string:tokens(binary_to_list(BinStr), " ")).

%% Вариант №2 без string
%% =====================
start2(BinStr, Num) ->
  cut_word(BinStr, Num, 1).
cut_word(BinStr, Num, NumWord) when  NumWord == Num ->
  case binary:split(BinStr, <<" ">>) of
    [Word] -> binary_to_list(Word);
    [Word, _Rest] -> binary_to_list(Word)
  end;
cut_word(BinStr, Num, NumWord) ->
  case binary:split(BinStr, <<" ">>) of
    [_Word, Rest] -> cut_word(Rest, Num, NumWord+1);
    [_Str] -> {no_match}
  end.

%% Вариант №3 через binary:match
%% =============================
start3(BinStr, Num) ->
  cut_word3(BinStr, Num, 1).
cut_word3(BinStr, Num, NumWord) ->
  case binary:match(BinStr, <<" ">>) of
    nomatch ->
      if NumWord == Num -> binary_to_list(BinStr);
        true -> {no_match}
      end;
    {Pos, 1} ->
      if NumWord == Num -> binary_to_list(binary:part(BinStr, 0, Pos));
        true -> cut_word3(binary:part(BinStr, {byte_size(BinStr), -(byte_size(BinStr)-Pos-1)}), Num, NumWord+1)
      end
  end.
