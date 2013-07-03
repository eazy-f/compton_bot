-module(cbot).

-behaviour(supervisor).

-export([start/2, stop/1]).
-export([init/1]).

start(_, _) ->
    supervisor:start_link(?MODULE, []).

stop(_) ->
    ok.

init([]) ->
    { ok, Host } = application:get_env(host),
    { ok, Port } = application:get_env(port),
    BotSrv = { cbot_srv, { cbot_srv, start_link, [ Host, Port ] },
                           permanent, 1000, worker, [ cbot_srv ] },
    { ok, { { one_for_one, 5, 1000 }, [ BotSrv ] } }.


