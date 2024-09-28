## Moamen-Discord-Bot

A discord bot written in lua using [discordia](https://github.com/SinisterRectus/Discordia)

I'm aware of how bad and unreadable my code is.
If you wish to suffer, you could run the bot on your server.
If you are here to read the source code, you should read in this order:
`main.lua`, `Bot.lua`, `EventsToBind.lua`, and then whatever.

### How To Build

#### Method 1: Quick Setup
- Install Luvit: visit https://luvit.io and follow the instructions provided for your platform.
- Update the IDs allocated in `Enums.lua` and `Commands.lua` for the Roles embed command.
- Place your token in the token variable allocated in `main.lua`.
- To start the bot: run `luvit bot.lua`


#### Method 2: Full Setup

- Delete deps dir (if it exists)
- Install Luvit: visit https://luvit.io and follow the instructions provided for your platform.
- Install Discordia: run `lit install SinisterRectus/discordia`
- Install Sqlite3 Bindings:
```bat
cd .\.deps\
lit install SinisterRectus/sqlite3
```

- Clone extensions:
```git
git clone https://github.com/GitSparTV/discordia-slash
git clone https://github.com/Bilal2453/discordia-interactions
git clone https://github.com/Bilal2453/discordia-components
git clone https://github.com/Bilal2453/discordia-modals
```
- Update the IDs allocated in `Enums.lua` and `Commands.lua` for the Roles embed command.
- Place your token in the token variable allocated in `main.lua`.
- To start the bot: run `luvit bot.lua`
