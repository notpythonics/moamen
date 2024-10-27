local discordia = require("discordia")

local Enums = {
    Colors = {
        Default = discordia.Color.fromRGB(1, 1, 1).value,
        ModeratorAction = discordia.Color.fromRGB(27, 57, 74).value,
        Permission = discordia.Color.fromRGB(122, 78, 192).value,
        Block = discordia.Color.fromRGB(102, 0, 51).value,
        Giving_Roles = discordia.Color.fromRGB(60, 119, 80).value
    },

    Roles = {
        Moderator = "1028991149844729907",
        Blocked = "1266515724252483606",
        Member = "1061699881531605072",
        Bot = "1060206390058176532",
        Everyone = "1028991149806981140",
        EmbedsApprover = "1299993049107271721",

        Levels = {
            UI1 = "1248597904608723055",
            UI2 = "1248597938876317767",
            UI3 = "1248597932354306058",

            VFX1 = "1248601384480411728",
            VFX2 = "1248601388041240616",
            VFX3 = "1248601273142349825",

            GFX1 = "1248596255769100298",
            GFX2 = "1248596226551844874",
            GFX3 = "1248596242653515826",

            ANIMATION1 = "1248599633270280295",
            ANIMATION2 = "1248599627008311316",
            ANIMATION3 = "1248599628933369877",

            MODELER1 = "1248591907408445450",
            MODELER2 = "1248591874135035914",
            MODELER3 = "1248592192965054507",

            BUILDER1 = "1248594385277292595",
            BUILDER2 = "1248594345754492949",
            BUILDER3 = "1248594493196865546",
            BUILDER4 = "1284971300313366549",

            PROGRAMMER1 = "1248589468123009075",
            PROGRAMMER2 = "1248589521155784734",
            PROGRAMMER3 = "1248590393180950559",
            PROGRAMMER4 = "1254536052320768182"
        }
    },

    Emojis = {
        UI1 = "1248610488275828848",
        VFX1 = "1248610479232909332",
        GFX1 = "1248610490855325738",
        MODELER1 = "1248610501118922874",
        ANIMATION1 = "1248610481606885486",

        BUILDER4 = "1284971140485484576",
        PROGRAMMER4 = "1248588585590980649",

        -- Hash
        What = "what:1268763017257160794",
        Delete_this = "delete_this:1265414312483229706"
    },

    Images = {
        Header = "https://i.imgur.com/wohhlXN.png",
        BigHeader = "https://i.imgur.com/mJ1Cc83.png"
    },

    Categories = {
        AskForRoles = "1248614752750403604"
    },

    Channels = {
        your_games = "1202308818139091026",
        your_doings = "1028991151467933758",
        fetured = "1266047330294169672",

        lfd_server = "1269548878127038555",
        fh_server = "1269552699871854673",
        sell_server = "1272655494573588672",

        lfd_embed_channel = "1269541709440618496",
        fh_embed_channel = "1269552636810494038",
        sell_embed_channel = "1272655777110163598",

        shop = {
            lfd = {
                builder = "1269935482247053355",
                programmer = "1269939988955664458",
                gfx = "1269940793603264554",
                modeler = "1269941951386615850",
                vfx = "1269942647401877575",
                animation = "1269942971894071316",
                ui = "1269944751638183946"
            },

            fh = {
                builder = "1269950847832424488",
                programmer = "1269950696648867851",
                gfx = "1269950996394545223",
                ui = "1269951073158959138",
                animation = "1269951187755466782",
                modeler = "1269951402558361673",
                vfx = "1269951473396224041"
            },

            sell = "1272657563632275466"
        },

        Logs = {
            Embeds = "1273293492818546748",
            Members_movements = "1028991154936614962",
            Message_holder = "1028991154936614966"
        },

        Staff = {
            Blocked = "1154050882682503253"
        }
    }
}

return Enums
