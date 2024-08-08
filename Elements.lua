local discordia = require('discordia')

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
            discordia.Button('not_saty') -- id
            :label 'مو راضي فيها'
            :style 'danger'
    },

    accept_and_decline_shop_request =  discordia.Components {
        discordia.Button('request_accept') -- id
            :label 'قبول'
            :style 'secondary',
            discordia.Button('request_decline') -- id
            :label 'رفض'
            :style 'danger'
    }
}

elements.images = {
    header = {url = 'https://i.imgur.com/cnDU7OJ.png'},

    line = {url = 'https://i.imgur.com/7mpSyyH.png'}
}

return elements