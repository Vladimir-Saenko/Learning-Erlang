%%%-------------------------------------------------------------------
%%% @author siborg
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(learning_erl).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1,stop/0]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  SupFlags = #{strategy => one_for_one,
    intensity => 2,
    period => 3600},
  ChildSpecs = [child(req_serv),child(rep_server)],
  {ok, {SupFlags, ChildSpecs}}.

stop() ->
  exit(whereis(?SERVER), shutdown).

child(Module) ->
  #{id => Module,
    start => {Module, start_link, []},
    restart => permanent,
    shutdown => 2000,
    type => worker,
    modules => [Module]}.

%% internal functions
