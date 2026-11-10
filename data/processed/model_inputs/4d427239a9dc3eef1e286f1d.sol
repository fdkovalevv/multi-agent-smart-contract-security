contract Faucet {

    event didFund(address targetAddress, uint remainingBalance);

    bool _mutex = false;

    uint _sendCount = 0;
    uint _receiveCount = 0;

    function Faucet() { }

    function fund(address targetAddress) {
        if (_mutex) { throw; }
        _mutex = true;
        _sendCount++;

                                   
        bool success = targetAddress.send(0x2b992ddfa23249d6);
        if (!success) { throw; }

                                                                      
        success = msg.sender.send(0x16345785d8a0000);
        if (!success) { throw; }

        didFund(targetAddress, this.balance);

        _mutex = false;
    }

    function() payable {
        if (_mutex) { throw; }
        _receiveCount++;
    }

    function getStatus() constant returns (uint sendCount, uint receiveCount) {
        return (_sendCount, _receiveCount);
    }
}