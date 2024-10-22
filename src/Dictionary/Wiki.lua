local discordia = require("discordia")

local Wiki = {}

Wiki.ticket_close_algorithm = {
    image = {
        url = "https://i.imgur.com/NWLksPt.png"
    },
    fields = {
        {
            name = "مالك الروم",
            value =
            "```lua\nlocal user_who_made_channel = intr.channel:getFirstMessage().mentionedUsers.first\nlocal member_who_made_channel = self.guild:getMember(user_who_made_channel.id)\n```",
        },
    },
}

Wiki.c_structs = {
    image = {
        url = "https://i.imgur.com/N5ir1GA.png"
    },
    description =
    "C does not have member functions or constructors; It only has data members. This means every struct in C is an aggregate!\nnote that function members do not make a struct non-aggregate but constructors and protected/private members do.\n[learncpp](https://www.learncpp.com/cpp-tutorial/member-functions/)"
}

Wiki.deleting_functions = {
    image = {
        url = "https://i.imgur.com/DNfAWT7.png"
    },
    title = "deleting functions",
    description =
    "```cpp\nclass Foo {\npublic:\n  Foo() = delete; // forbid def con\n  Foo(const Foo& f) = delete; // forbid copy con\n};```\n`= delete;` --> I forbid this\n[learncpp](https://www.learncpp.com/cpp-tutorial/deleting-functions/)"
}

Wiki["std::pair"] = {
    image = {
        url = "https://i.imgur.com/GsAKmId.png"
    },
    title = "std::pair",
    description =
    "```cpp\n#include <utility>\n\n{std::pair p<int, double>{1, 3.1};}\nstd::pair p{1.1, 5}; // deduction```\n[learncpp](https://www.learncpp.com/cpp-tutorial/class-templates/)"
}

Wiki.linkage = {
    image = {
        url = "https://i.imgur.com/C3BVrJY.png"
    },
    title = "linkage",
    description =
    "```cpp\nint x = 1; // external\nstatic int xx = 1; // internal\n\nconst int z = 3; // internal\nconstexpr int zz = 3; // internal\ninline const int zzz = 3; // external\ninline constexpr int zzzz = 3; // external\n\n{int o = 7;} // no linkage\n\nvoid foo(){} // external\nstatic void doo(){} // internal\n\nnamespace { // internal\n  int o = 1; // internal\n}\nnamespace om { // external\n  int o = 2; // external\n}```\n[learncpp](https://www.learncpp.com/cpp-tutorial/scope-duration-and-linkage-summary/)"
}

Wiki.const_objects = {
    image = {
        url = "https://i.imgur.com/Z8PNc0F.png"
    },
    description =
    "```cpp\nstruct Date {\n  int year{};\n  int month{};\n\n  void print() {\n    std::cout << year << '/' month;\n  }\n};\n\nvoid something(const Date& date){\n  date.print(); // error\n}\n\nint main(){\n  Date date{1, 3};\n  something(date);\n}```\n[learncpp](https://www.learncpp.com/cpp-tutorial/const-class-objects-and-const-member-functions/)"
}

Wiki.reseting_state_and_chaining = {
    image = {
        url = "https://i.imgur.com/u9bL4xE.png"
    },
}

Wiki.delegating_constructors = {
    description =
    "```cpp\npublic:\n  Employee(std::string_view name)\n   : Employee{name, 0}{} // delegate initialization to another con\n\nEmployee(std::string_view name, int id)\n   : m_name{ name }, m_id{ id }{}```\n[learncpp](https://www.learncpp.com/cpp-tutorial/delegating-constructors/)\n[what is delegation](https://www.youtube.com/watch?v=PRFQTiFxV-M&t=86s&ab_channel=MatterhornBusinessDevelopment)"
}

Wiki.static_data_members = {
    image = {
        url = "https://i.imgur.com/EpGtRZS.png"
    },
    description =
    "```cpp\nclass Something {\n  // Note: it's private\n  static int s_value; // declaration\n};\n\nint Something::s_value{1}; // definition\n```\n[learncpp](https://www.learncpp.com/cpp-tutorial/static-member-variables/)"
}

Wiki.cmds = {
    --title = "commands",
    fields = {
        {
            name = "thanking",
            value = "`/thank`\n`/mythanks`\n`their_thanks`",
            inline = true
        },

        {
            name = "muting",
            value = "`mute`\n`unmute`",
            inline = true
        },

        {
            name = "blocking",
            value =
            "`is_id_blocked` takes an ID\n`send_blocked_message`\n`update_blocked_message`\n`blocked_members` number of blocked members\n`fblock` forced block (removes roles)\n`block` blocks members\n`unblock` unblocks members",
            inline = false
        },

        {
            name = "banning",
            value = "`ban` the maximum is 7 days\n`unban`",
            inline = false
        },

        {
            name = "embeds",
            value =
            "`roles_embed` sends an embed for applying to roles\n`fe_embed` sends an embed of an attachment or link found in a referenced message\n`erase` stops the process of filling an embed shop\n`shop_embeds`\n`rules_embed`",
            inline = false
        },

        {
            name = "perms",
            value =
            "`disallow_send_perm` disallows members from sending messages in a given channel\n`disallow_read_perm` disallows members from seeing a given channel\n`allow_send_perm`\n`allow_read_perm`\n`lock`\n`unlock`",
            inline = false
        },

        {
            name = "others",
            value =
            "`give_role` gives a given role to a given member (removes corresponding roles)\n`assign_mods` assigns moderators\n`remove_mods` removes moderators\n`source_code`\n`kick`\n`wiki` see wikihelp for more info\n`wikihelp`\n`header`\n`bigheader`",
            inline = false
        },

        {
            name = "bots",
            value =
            "`disallow_bots_entry` prevnts bots from joining\n`allow_bots_entry` premit bots from joining\n`bots_entry` a bool that determines if bots entry is allowed\n`deletegpc` delete guild app cmds\n`creategpc` create guild app cmds",
            inline = false
        },
    }
}

Wiki.ai = {
    title = "AI",
    image = {
        url = "https://i.imgur.com/t9vFgpO.png"
    },
    description =
    [[نوصي بشدة بعدم استخدام الذكاء الاصطناعي وأي نموذج ذكي لأن

النماذج الذكية ليست جيدة في ++C أو Lua
النماذج الذكية تكون خاطئة في كثير من الأحيان
النماذج الذكية تجيب بثقة كاملة حتى عندما تكون الإجابات خاطئة

> إذا كنت جديدًا في البرمجة، فمن المحتمل أنك لا تعرف بما فيه الكفاية لتحديد متى تكون الإجابات خاطئة]],
    color = discordia.Color.fromRGB(1, 1, 1).value, -- 💩
}

do
    local local_embed = {
        fields = {
            {
                name = "كيف تتعلم",
                value = "نوصي عموما بمصادر جيدة للتعلم، منها\n\n",
                inline = false
            },

            {
                name = "Lua <:Lua:1281249211580551209>",
                value =
                "[قناة عارف](https://www.youtube.com/@aref_r)\n[Programming in Lua](https://www.lua.org/pil/contents.html)",
                inline = false
            },

            {
                name = "C++ <:cpp:1225864684163305573>",
                value =
                "[learncpp](https://www.learncpp.com/)\n[Principles and practice using c++](https://t.me/+H1cOWd42ocFkMTQ0)",
                inline = false
            }
        }
    }

    Wiki.htl = local_embed
    Wiki.how_to_learn = local_embed
end
-- classes/images/first_mention.png

return Wiki
