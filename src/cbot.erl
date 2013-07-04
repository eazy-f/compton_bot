-module(cbot).

-behaviour(supervisor).

-export([start/2, stop/1]).
-export([init/1]).

start(_, _) ->
    Sup = { ok, Pid } = supervisor:start_link(?MODULE, []),
    { ok, BotNum } = application:get_env(bot_number),
    [ start_bot(Pid, get_name(N)) || N <- lists:seq(1, BotNum) ],
    Sup.
    

stop(_) ->
    ok.

init([]) ->
    { ok, Host } = application:get_env(host),
    { ok, Port } = application:get_env(port),
    BotSrv = { cbot_srv, { cbot_srv, start_link, [ Host, Port ] },
                           permanent, 1000, worker, [ cbot_srv ] },
    { ok, { { simple_one_for_one, 5, 1 }, [ BotSrv ] } }.

get_name(N) ->
    list_to_binary("playa" ++ integer_to_list(N)).

start_bot(Sup, Name) ->
    { ok, _ } = supervisor:start_child(Sup, [Name] ).
