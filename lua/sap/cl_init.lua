local sap = sap

net.Receive('sap:NewTicket', function()
    print('test')
end)

net.Receive('sap:CloseTicket', function()
    print('hello')
end)