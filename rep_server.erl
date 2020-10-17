%%%-------------------------------------------------------------------
%%% @author siborg
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(rep_server).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).
-export([stop/1,take_item/2]).

-define(SERVER, ?MODULE).

-record(rep_server_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #rep_server_state{}}.

handle_call(terminate,_From,State) ->
  {stop,normal,ok,State};

handle_call({take,Item},_From,State) ->
  {reply,{please,Item},State};

handle_call(_Request, _From, State = #rep_server_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #rep_server_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #rep_server_state{}) ->
  {noreply, State}.

terminate(_Reason, _State = #rep_server_state{}) ->
  io:format("Сервер-обработчик выключен~n"),
  ok.

code_change(_OldVsn, State = #rep_server_state{}, _Extra) ->
  {ok, State}.

%%===================================================================
%%% API
%%%===================================================================

stop(Pid) ->
  gen_server:call(Pid,terminate).

take_item(Pid,Item) ->
  gen_server:call(Pid,{take,Item}).

%%%===================================================================
%%% Internal functions
%%%===================================================================
