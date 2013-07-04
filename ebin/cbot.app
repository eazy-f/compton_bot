{ application, cbot, [
  { description, "Dominion game Compton bot" },
  { module, [] },
  { applications, [ kernel ] },
  { mod, { cbot, [] } },
  { modules, [ cbot, cbot_srv ] },
  { env, [ 
    { host, "192.168.1.7" },
    { port, 6666 },
    { bot_number, 15 }
  ]}
]}.