local Enums = require("./Enums")

local HowTo = {}

HowTo["خوارزمية صاحب التكت"] = {
    color = Enums.Colors.Default,
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

HowTo["Source Code"] = {
    color = Enums.Colors.Default,
    title = "source code",
    description =
    "repo: [moamen](https://github.com/notpythonics/moamen)\n`git clone https://github.com/notpythonics/moamen`\n-->change enums and replace token\n->run batch file\nyou can't be a contributor go away"
}

HowTo["C Structs"] = {
    color = Enums.Colors.Default,
    image = {
        url = "https://i.imgur.com/N5ir1GA.png"
    },
    description =
    "C does not have member functions or constructors; It only has data members. This means every struct in C is an aggregate!\nnote that function members do not make a struct non-aggregate but constructors and protected/private members do.\n[learncpp](https://www.learncpp.com/cpp-tutorial/member-functions/)"
}

HowTo["Deleting Functions"] = {
    color = Enums.Colors.Default,
    image = {
        url = "https://i.imgur.com/DNfAWT7.png"
    },
    title = "deleting functions",
    description =
    "```cpp\nclass Foo {\npublic:\n  Foo() = delete; // forbid def con\n  Foo(const Foo& f) = delete; // forbid copy con\n};```\n`= delete;` --> I forbid this\n[learncpp](https://www.learncpp.com/cpp-tutorial/deleting-functions/)"
}

HowTo["std::pair"] = {
    color = Enums.Colors.Default,
    image = {
        url = "https://i.imgur.com/GsAKmId.png"
    },
    title = "std::pair",
    description =
    "```cpp\n#include <utility>\n\n{std::pair p<int, double>{1, 3.1};}\nstd::pair p{1.1, 5}; // deduction```\n[learncpp](https://www.learncpp.com/cpp-tutorial/class-templates/)"
}

HowTo["Linkage"] = {
    color = Enums.Colors.Default,
    image = {
        url = "https://i.imgur.com/C3BVrJY.png"
    },
    title = "linkage",
    description =
    "```cpp\nint x = 1; // external\nstatic int xx = 1; // internal\n\nconst int z = 3; // internal\nconstexpr int zz = 3; // internal\ninline const int zzz = 3; // external\ninline constexpr int zzzz = 3; // external\n\n{int o = 7;} // no linkage\n\nvoid foo(){} // external\nstatic void doo(){} // internal\n\nnamespace { // internal\n  int o = 1; // internal\n}\nnamespace om { // external\n  int o = 2; // external\n}```\n[learncpp](https://www.learncpp.com/cpp-tutorial/scope-duration-and-linkage-summary/)"
}

HowTo["Const Objects"] = {
    color = Enums.Colors.Default,
    image = {
        url = "https://i.imgur.com/Z8PNc0F.png"
    },
    description =
    "```cpp\nstruct Date {\n  int year{};\n  int month{};\n\n  void print() {\n    std::cout << year << '/' month;\n  }\n};\n\nvoid something(const Date& date){\n  date.print(); // error\n}\n\nint main(){\n  Date date{1, 3};\n  something(date);\n}```\n[learncpp](https://www.learncpp.com/cpp-tutorial/const-class-objects-and-const-member-functions/)"
}

HowTo["Reseting State and Chaining"] = {
    color = Enums.Colors.Default,
    image = {
        url = "https://i.imgur.com/u9bL4xE.png"
    },
}

HowTo["Delegating Constructors"] = {
    color = Enums.Colors.Default,
    description =
    "```cpp\npublic:\n  Employee(std::string_view name)\n   : Employee{name, 0}{} // delegate initialization to another con\n\nEmployee(std::string_view name, int id)\n   : m_name{ name }, m_id{ id }{}```\n[learncpp](https://www.learncpp.com/cpp-tutorial/delegating-constructors/)\n[what is delegation](https://www.youtube.com/watch?v=PRFQTiFxV-M&t=86s&ab_channel=MatterhornBusinessDevelopment)"
}

HowTo["Static Data Members"] = {
    color = Enums.Colors.Default,
    image = {
        url = "https://i.imgur.com/EpGtRZS.png"
    },
    description =
    "```cpp\nclass Something {\n  // Note: it's private\n  static int s_value; // declaration\n};\n\nint Something::s_value{1}; // definition\n```\n[learncpp](https://www.learncpp.com/cpp-tutorial/static-member-variables/)"
}

HowTo["كيف تتعلم"] = {
    color = Enums.Colors.Default,
    fields = {
        {
            name = "كيف تتعلم",
            value = "نوصي عموما بمصادر جيدة للتعلم، منها\n\n",
            inline = false
        },

        {
            name = "Lua <:Lua:1281249211580551209>",
            value =
            "[عارف](https://www.youtube.com/@aref_r)\n[Programming in Lua](https://www.lua.org/pil/contents.html)\n[BrawlDev](https://youtube.com/playlist?list=PLQ1Qd31Hmi3W_CGDzYOp7enyHlOuO3MtC&si=7s0gzEjVE2DwOeZy)\n[TheDevKing](https://youtube.com/playlist?list=PLhieaQmOk7nIfMZ1UmvKGPrwuwQVwAvFa&si=Re_z9JhNGaHsb_Rs)\n[The Ultimate Scripting Mastery Course](https://t.me/+eLrehE3tH7U2NzNk)",
            inline = false
        },

        {
            name = "C++ <:cpp:1225864684163305573>",
            value =
            "[learncpp](https://www.learncpp.com/)\n[Principles and Practice Using C++](https://t.me/+H1cOWd42ocFkMTQ0)",
            inline = false
        },

        {
            name = "مشورة",
            value =
            "> شوف القناة الي تعجبك وكمل معها",
            inline = false
        },
    }
}

HowTo["القراءة والجيل الحالي"] = {
    color = Enums.Colors.Default,
    title = "AI",
    description =
    [[يجب أن ندرك أن كل شيء نريد أن نتعلمه لا يتطلب فيديو أو مادة مرئية.
    أحيانًا، يكون من الأفضل العودة إلى أصول التعلم التقليدية وتجربة قراءة كتاباً.
    الكتب هي الوسيلة التي اعتمد عليها العلماء عبر التاريخ لنقل العلم والأفكار.

    ```diff
    + القراءة الإلكترونية مساوية للقراءة الورقية!
    ```
    **قراءة الكتب لا تنقرض**
    ||الجيل الحالي تعود على المواد المرئية لا يريد أن يقرأ كتاباً||]]
}

HowTo["ذكاء الاصطناعي"] = {
    color = Enums.Colors.Default,
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
}

HowTo["Line, Segment and Point"] = {
    color = Enums.Colors.Default,
    title = "Line, Segment and Point",
    image = {
        url = "https://i.imgur.com/FJtMSfp.png"
    },
    description =
    [[**line**: A line is like a thin, straight wire (although really it’s infinitely thin — or better yet, it has no width at all). Lines have length, so they’re one-dimensional. Remember that a line goes on forever in both directions, which is why you use the little double-headed arrow as in AB (read as line AB). Check out `Figure 2-1`. Lines are usually named using any two points on the line, with the letters in any order. So MQ is the same line as QM, MN is the same as NM, and QN is the same as NQ. Occasionally, lines are named with a single, italicized, lowercase letter, such as lines f and g.

    **Line segment (or just segment)**: A segment is a section of a line that has two endpoints. See Figure 2-1 yet again. If a segment goes from P to R, you call it segment PR and write it as PR. You can also switch the order of the letters and call it RP . Segments can also appear within lines, as in MN. `Note:` A pair of letters without a bar over it means the length of a segment. For example, PR means the length of PR.

    **Point**: A point is like a dot except that it actually has no size at all; or you can say that it’s infinitely small (except that even saying infinitely small makes a point sound larger than it really is). Essentially, a point is zero-dimensional, with no height, length, or width, but you draw it as a dot, anyway. You name a point with a single uppercase letter, as with points A, D, and T in Figure 2-1.
    ]]
}
-- classes/images/first_mention.png

return HowTo
