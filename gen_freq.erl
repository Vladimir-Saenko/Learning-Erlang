%%%-------------------------------------------------------------------
%%% @author siborg
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(gen_freq).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).
-export([stop/0, allocate/0, deallocate/1]).

-define(SERVER, ?MODULE).

-record(gf_state, {free, alloc}).

%%%===================================================================
%%% Порождение и инициализация
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  Free = [10, 11, 12, 13, 14, 15],
  {ok, #gf_state{free = Free, alloc = []}}.

%%%==================================================================
%%% API клиента
%%%==================================================================

stop() -> gen_server:call(?SERVER, terminate).
allocate() -> gen_server:call(?SERVER, allocate).
deallocate(Freq) -> gen_server:call(?SERVER, {deallocate, Freq}).

%%%==================================================================
%%% Функции обратного вызова
%%%==================================================================

handle_call(allocate, From, State) ->
  {Reply, NewState} = allocate_freq(From, State),
  {reply, Reply, NewState};

handle_call({deallocate,Freq}, From, State) ->
  {Reply,NewState} = deallocate_freq(Freq, From, State),
  {reply, Reply, NewState};

handle_call(terminate, _From, State) ->
  {stop, normal, ok, State}.

handle_cast(_Request, State = #gf_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #gf_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #gf_state{}) ->
  ok.

code_change(_OldVsn, State = #gf_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Внутренние функции
%%%===================================================================

allocate_freq(From, State = #gf_state{}) ->
  Free = State#gf_state.free,
  Allocated = State#gf_state.alloc,
  {Pid,_} = From,
  case Free of
    [] -> {{error,no_frequency},State};
    [Freq|Rest] ->
      NewState = #gf_state{free=Rest,alloc=[{Freq,Pid}|Allocated]},
      io:format("State = ~p~nNewState = ~p~n~n",[State,NewState]),
      {{ok,Freq},NewState}
  end.

deallocate_freq(Freq, From, State = #gf_state{}) ->
  Free = State#gf_state.free,
  Allocated = State#gf_state.alloc,
  {Pid,_} = From,
  case lists:member({Freq, Pid},Allocated) of
    true ->
      NewAllocated = lists:delete({Freq,Pid},Allocated),
      NewFree = [Freq|Free],
      NewState = #gf_state{free=NewFree,alloc=NewAllocated},
      io:format("State = ~p~nNewState = ~p~n~n",[State,NewState]),
      {ok,NewState};
    false ->
      {invalid_frequency,State}
  end.