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
    { ok, Num } = application:get_env(bot_number),
    Spec = { cbot_ctrl, { cbot_ctrl, start_link, [ Host, Port, Num ] },
             permanent, 1000, worker, [ cbot_ctrl ] },
    { ok, { { one_for_one, 5, 1 }, [ Spec ] } }.
