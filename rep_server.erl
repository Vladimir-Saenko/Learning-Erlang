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
-export([stop/0,take_item/1,store_item/1,work_req/3]).

-define(SERVER, ?MODULE).

%%-record(rep_server_state, {}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) -> {ok, []}.

handle_call(terminate,_From,State) ->
  {stop,normal,ok,State};

handle_call({take,Item},From,State) ->
  case lists:member(Item,State) of
    true ->
      NewState = lists:delete(Item,State),
      proc_lib:spawn_link(?SERVER, work_req,[take,From,Item]),
      {noreply,NewState};
    _ ->
      {reply,{error,not_exists},State}
  end;

handle_call({store,Item},From,State) ->
  proc_lib:spawn_link(?SERVER, work_req,[store,From,Item]),
  {noreply,[Item|State]};

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast({store,From,Item},State) ->
  proc_lib:spawn_link(?SERVER, work_req,[store,From,Item]),
  {noreply,[Item|State]};

handle_cast(_Request, State ) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  io:format("Сервер-обработчик выключен~n"),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.



%%===================================================================
%%% API
%%%===================================================================

stop() ->
  gen_server:call(?SERVER,terminate).

take_item(Item) ->
  gen_server:call(?SERVER,{take,Item}).

store_item(Item) ->
  gen_server:call(?SERVER,{store,Item}).

%%%===================================================================
%%% Internal functions
%%%===================================================================

work_req(Order,From,Item) ->
  proc_lib:init_ack(ok),
  timer:sleep(1000),
  gen_server:reply(From,{{Order,ok},Item}).

