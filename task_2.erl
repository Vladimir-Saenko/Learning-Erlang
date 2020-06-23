%%%-------------------------------------------------------------------
%%% @author Владимир 'siborg' Саенко
%%% @doc
%%% Задачки от Revent-а, чтобы сломать мозг и бросить учить Erlang
%%% ==================================================================
%%% Задача №2
%%% На входе: список типа [test1, test2, test3, test4], элемент и направление
%%% Задача: сдвиг элемента в списке в заданном направлении за один проход
%%% @end
%%% Created : 28. май 2020 11:20
%%%-------------------------------------------------------------------
-module(task_2).
-author("Владимир 'siborg' Саенко").

%% API
-export([start1/3, start2/3, start3/3, start4/3]).

%% Вариант №1 Переписанный
%% ==========
start1(L, Element ,Direction) when length(L) > 1 ->                 % Проверка достаточной длины списка
  case lists:member(Element, L) of                                  % Проверяем наличие елемента в списке
    true -> case Direction of                                       % Определяем направление
              right -> shift(L, Element);                           % если вправо, функция сдвига
              _ -> lists:reverse(shift(lists:reverse(L), Element))  % если влево, то реверс функции
            end;                                                    % сдвига от реверсивного списка
    _ -> {error, element_not_in_list}                               % ошибка - элемента нет в списке
  end;
start1(_, _, _) -> {error, very_short_list}.                        % ошибка - короткий список

shift(L, Element) ->
  case lists:last(L) of                                            % Если искомый элемент последний в списке то
      Element -> L;                                                % оставляем список как был,
      _ -> L1 = lists:takewhile(fun(X) -> X =/= Element end, L),   % иначе, извлекаем начало списка до Element
           [X|L2] = lists:delete(Element,lists:subtract(L,L1)),    % извлекаем в Х следующий за ним эелемент
           lists:append([L1,[X], [Element],L2])                    % и склеиваем новый список, меняя местами Element
  end.                                                             % и следующий за ним элемент списка

%% Вариант №2
%% ==========
start2(L, Element, Direction) when length(L) > 1->                      % Проверка достаточной длины списка
  case lists:member(Element, L) of                                      % Проверяем наличие елемента в списке
    true -> case Direction of                                           % Определяем направление
              right -> shift2(L, Element, "");                          % если вправо, функция сдвига
              _ -> lists:reverse(shift2(lists:reverse(L), Element, "")) % если влево, то реверс функции
            end;                                                        % сдвига от реверсивного списка
    _ -> {error, element_not_in_list}                                   % ошибка - элемента нет в списке
  end;
start2(_, _, _) -> {error, very_short_list}.                            % ошибка - короткий список

shift2([X, Y | []], Element, Acc) ->                  % берем в X и Y последние 2 элемента списка
  if X =:= Element ->                                 % если X это Element,
       lists:reverse(Acc) ++ [Y, X];                  % то реверсируем аккумулятор и приклеиваем
                                                      % поменяные местами элементы головы
     true -> lists:reverse(Acc) ++ [X, Y]             % а если Y это Element, то не меняем местами
  end;
shift2([X, Y | T], Element, Acc) ->                   % отделяем 2 первых элемента списка
  case X of                                           % если X это Element, то реверсируем
    Element -> lists:reverse(Acc) ++ [Y, X] ++ T;     % аккумулятор, меняем местами X и Y и клеим хвост
    _ -> shift2([Y | T], Element, [X|Acc])            % иначе рекурсия отсекая первый элемент
  end.

%% Вариант №3 через fold
%% =====================
start3(L, Element, Direction) when length(L) > 1->                  % Проверка достаточной длины списка
  case lists:member(Element, L) of                                  % Проверяем наличие елемента в списке
    true -> case Direction of                                       % Определяем направление
              left -> shift3(L, Element);                          % если вправо, функция сдвига
              _ -> lists:reverse(shift3(lists:reverse(L), Element)) % если влево, то реверс функции
            end;                                                    % сдвига от реверсивного списка
    _ -> {error, element_not_in_list}                               % ошибка - элемента нет в списке
  end;
start3(_, _, _) -> {error, very_short_list}.                        % ошибка - короткий список

shift3(L, Element) ->
  case lists:nth(1, L) of                  % Если первый элемент списка это
    Element -> L;                          % Element, то возвращаем список без изменений
    _ -> F = fun(X, Acc) ->                % функция для fold
      if X =/= Element -> [X | Acc];       % Если X не Element, то кидаем в аккумулятор
        true -> [Y | Acc1] = Acc,          % иначе
          [Y, X | Acc1]                    % меняем местами голову аккумулятора и X
      end
             end,
      lists:reverse(lists:foldl(F, "", L))
  end.

%% Вариант Revent-a
%% ================
start4(L, Element, right) ->
  lists:foldr(
    fun(Elem, Acc) ->
      case Acc of
        [Down | T] when Elem == Element ->
          [Down, Elem | T];
        _ -> [Elem | Acc]
      end
    end, [], L);
start4(L, Element, left) ->
  lists:reverse(lists:foldl(fun(Elem, Acc) ->
  case Acc of
    [Up | T] when Elem == Element ->
      [Up, Elem | T];
    _ -> [Elem | Acc]
  end
  end, [], L)).