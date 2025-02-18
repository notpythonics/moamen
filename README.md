## Moamen-Discord-Bot

A discord bot written in lua using [discordia](https://github.com/SinisterRectus/Discordia)

I'm aware of how bad and unreadable my code is.
If you wish to suffer, you could run the bot on your server.
If you are here to read the source code, you should read in this order:
`main.lua`, `Bot.lua`, `EventsToBind.lua`, and then whatever.

### How To Build
- Clone this repo and move to moamen dir:
```bat
git clone https://github.com/notpythonics/moamen
cd .\.moamen\
```

- Install Luvit: visit https://luvit.io/install.html and follow the instructions provided for your platform.

- Clone extensions:
```bat
cd .\.deps\
git clone https://github.com/GitSparTV/discordia-slash
git clone https://github.com/Bilal2453/discordia-interactions
git clone https://github.com/Bilal2453/discordia-components
git clone https://github.com/Bilal2453/discordia-modals
```

- Update the IDs allocated in `Enums.lua`
- Place your token in the token variable allocated in `main.lua`
- To start the bot: run `luvit main.lua` or `build.bat`

![Shop](https://i.imgur.com/USC8mw8.png)
![More than 105 doc](https://i.imgur.com/0TKcDJG.png)
