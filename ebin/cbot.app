{ application, cbot, [
  { description, "Dominion game Compton bot" },
  { module, [] },
  { applications, [ kernel ] },
  { mod, { cbot, [] } },
  { modules, [ cbot, cbot_srv, cbot_ctrl ] },
  { env, [ 
    { host, "192.168.1.4" },
    { port, 6666 },
    { bot_number, 15 }
  ]}
]}.