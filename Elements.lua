local discordia = require('discordia')
local dModals = require('discordia-modals')

local elements = {}

elements.buttons = {
    close_and_delete = discordia.Components {
        discordia.Button('delete') -- id
            :label 'حذف الروم'
            :style 'danger',
        discordia.Button('close') -- id
            :label '(سكره)قفل الروم'
            :style 'secondary'
    },

    sendShopRequest_and_notSaty = discordia.Components {
        discordia.Button('shop_request') -- id
            :label 'ارسال للتقديم'
            :style 'secondary',
        discordia.Button('not_saty')     -- id
            :label 'مو راضي فيها'
            :style 'danger'
    },

    accept_and_decline_shop_request = discordia.Components {
        discordia.Button('request_accept') -- id
            :label 'قبول'
            :style 'secondary',
        discordia.Button('request_decline')     -- id
            :label 'رفض'
            :style 'danger'
    }
}

elements.menus = {
    payment_type = discordia.Components {
        discordia.SelectMenu('payment_type') -- id
            :placeholder "اختر طريقة الدفع"
            :option('روبوكس', 'Robux', 'الدفع بستخدام روبوكس', false)
            :option('كردت', 'Credit', 'الدفع بستخدام كردت', false)
    },

    work_type = discordia.Components {
        discordia.SelectMenu('work_type') -- id
            :placeholder "اختر العمل"
            :option('مبرمج', 'programmer', 'يكتب سكربتات', false)
            :option('مودلر', 'modeler', 'يسوي مجسمات', false)
            :option('بلدر', 'builder', 'يركب اشياء فوق بعض', false)
            :option('مصمم جرافيك', 'gfx', 'يسوي صور', false)
            :option('مؤثرات بصرية', 'vfx', 'يسوي مؤثرات', false)
            :option('أنيميشن', 'animation', 'يسوي انيميشنات', false)
            :option('واجهة مستخدم', 'ui', 'يسوي واجهة مستخدم', false)
    }
}

elements.images = {
    header = { url = 'https://i.imgur.com/cnDU7OJ.png' },

    line = { url = 'https://i.imgur.com/7mpSyyH.png' }
}

elements.embeds = {
    payment_type = {
        title = 'طرق الدفع',
        description = 'ما طرق الدفع الي تتعامل فيها'
    },

    work_type = {
        title = 'البحث او الخبرة',
        description = 'ما خبرتك او الخبرة الي تبحث عنها',
        color = discordia.Color.fromRGB(0, 0, 0).value,
    },

    roles_embed =  {
        title = 'روم التقديم',
        description = 'شغلك واعمالك ارسلهم هنا',
        image = elements.images.header,
        color = discordia.Color.fromRGB(0, 0, 0).value,
    }
}

elements.textInputs = {
    decline_reason = dModals.TextInput({
        id = "decline_reason_textInput",
        style = "short",
        label = "السبب",
        placeholder = ""
    })
}

elements.modals = {
    decline_reason = dModals.Modal({
        title = 'رفض الإمبد',
        id = 'decline_reason_modal',
        elements.textInputs.decline_reason
    })
}

return elements
