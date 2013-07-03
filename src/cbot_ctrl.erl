-module(cbot_ctrl).

-behaviour(gen_server).

-export([start_link/3]).
-export([init/1, terminate/2, handle_info/2]).

-record(state, { host, port, bots }).

start_link(Hostname, Port, BotNum) ->
    gen_server:start_link(?MODULE, [Hostname, Port, BotNum], []).

init([ Hostname, Port, BotNum ]) ->
    process_flag(trap_exit, true),
    Bots = [ { start_bot(Hostname, Port, Name), Name } ||
               Name <- lists:map(fun get_name/1, lists:seq(1, BotNum) ) ],
    { ok, #state{
              host = Hostname,
              port = Port,
              bots = dict:from_list(Bots) }
    }.

handle_info({'EXIT', Pid, _}, #state{ host = Host, port = Port} = State) ->
    #state{ bots = Bots } = State,
    Name = dict:fetch(Pid, Bots),
    NewPid = start_bot(Host, Port, Name),
    Erased = dict:erase(Pid, Bots),
    { noreply, State#state{ bots = dict:store(NewPid, Name, Erased ) } }.

terminate(_, _) ->
    ok.

start_bot(Hostname, Port, Name) ->
    { ok, Pid } = cbot_srv:start_link(Hostname, Port, Name),
    Pid.

get_name(N) ->
    list_to_binary("playa" ++ integer_to_list(N)).
