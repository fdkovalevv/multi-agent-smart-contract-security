contract SendBack {
    function() payable {
        if (!msg.sender.send(msg.value))
            throw;
    }
}