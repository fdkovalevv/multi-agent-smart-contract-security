contract Owned {
    address private _owner;

    function Owned() {
        _owner = msg.sender;
    }

    function getOwner() constant returns (address owner) {
        return _owner;
    }
}

contract Remittances is Owned {
    uint public maxNumberOfBlocksInFuture;

    struct Remittance {
        address sender;
        uint amount;
        uint toea;
        uint blockDeadline;
    }

    mapping (bytes32 => Remittance) public remittances;

    event LogRemittanceAdded(address indexed sender, bytes32 indexed hash, uint value, uint toea, uint blockDeadline);
    event LogRemittanceCollected(address indexed sender, bytes32 hash, bytes8 indexed agentCode, bytes8 indexed receiverCode);
    event LogRemittanceReturned(address indexed sender, bytes32 indexed hash);

       
                           
                                                                                          
                                 
                                                                 
                                                                                
       
    function Remittances(uint _maxNumberOfBlocksInFuture) {
        maxNumberOfBlocksInFuture = _maxNumberOfBlocksInFuture;
    }

       
                                            
                                                                                       
                                                                       
                                                      
                                                            
       
    function anonymise(bytes8 agentCode, bytes8 receiverCode)
        constant
        returns (bytes32 hash) {
        return sha3(agentCode, receiverCode);
    }

       
                                                  
                                                                  
                                                                              
                                                                                          
       
    function sendTo(bytes32 hash, uint toea, uint blockDeadline)
        payable
        returns (bool success) {
        if (remittances[hash].amount > 0
            || block.number + maxNumberOfBlocksInFuture < blockDeadline) {
            throw;
        }
        remittances[hash] = Remittance({
            sender: msg.sender,
            amount: msg.value,
            toea: toea,
            blockDeadline: blockDeadline
        });
        LogRemittanceAdded(msg.sender, hash, msg.value, toea, blockDeadline);
        return true;
    }

       
                                                       
                                                                                         
             
                                                       
                                                             
       
    function collect(bytes8 agentCode, bytes8 receiverCode)
        returns (bool success) {
        bytes32 hash = anonymise(agentCode, receiverCode);
        Remittance storage remittance = remittances[hash];
        if (remittance.blockDeadline < block.number) {
            throw;
        }
        uint amount = remittance.amount;
        remittance.amount = 0;
        if (!msg.sender.call.value(amount)()) {
            throw;
        }
        LogRemittanceCollected(remittance.sender, hash, agentCode, receiverCode);
        return true;
    }

       
                                                                                      
                
                                                              
       
    function returnToSender(bytes32 hash)
        returns (bool success) {
        Remittance storage remittance = remittances[hash];
        if (block.number <= remittance.blockDeadline) {
            throw;
        }
        uint amount = remittance.amount;
        remittance.amount = 0;
        if (!remittance.sender.call.value(amount)()) {
            throw;
        }
        LogRemittanceReturned(remittance.sender, hash);
        return true;
    }
}