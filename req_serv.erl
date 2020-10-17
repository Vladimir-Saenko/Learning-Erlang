%%%-------------------------------------------------------------------
%%% @author siborg
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(req_serv).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
  code_change/3]).
-export([stop/0,store/1,take/1]).

-define(SERVER, ?MODULE).

-record(req_serv_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
  {ok, #req_serv_state{}}.

handle_call(terminate,_From,State) ->
  {stop,normal,ok,State};

handle_call({take,Item},_From,State) ->
  {reply,rep_server:take_item(Item),State};

handle_call(_Request, _From, State = #req_serv_state{}) ->
  {reply, ok, State}.

handle_cast(_Request, State = #req_serv_state{}) ->
  {noreply, State}.

handle_info(_Info, State = #req_serv_state{}) ->
  {noreply, State}.

terminate(normal, _State = #req_serv_state{}) ->
  io:format("Сервер запросов выключен~n"),
  ok.

code_change(_OldVsn, State = #req_serv_state{}, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% API
%%%===================================================================

stop() ->
  gen_server:call(?SERVER,terminate).

store(Item) ->
  gen_server:call(?SERVER,{store,Item}).

take(Item) ->
  gen_server:call(?SERVER,{take,Item}).

%%%===================================================================
%%% Internal functions
%%%===================================================================
