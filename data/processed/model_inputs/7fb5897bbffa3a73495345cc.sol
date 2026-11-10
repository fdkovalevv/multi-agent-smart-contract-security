contract IDCaseC{
    address public owner;                
    address public authorizer;                                            
    
    address requester;
    bytes32 hash;
    address adr;
    
    modifier onlyOwner() { 
        if(msg.sender == owner)
            _;
    }
    modifier onlyAuthorizer() { 
        if(msg.sender == authorizer)
            _;
    }
    
    function IDCaseC(){
        owner = msg.sender;
    }
    
    function changeAuthorizer(address _authorizer) onlyOwner() {
        authorizer = _authorizer;
    }
    
    function requestKnowledge(bytes32 _hash) {
        if(msg.value >= 1) {
            hash = _hash;
            requester = msg.sender;
        }
        else 
            throw;
    }
    function proveKnowledge(bytes message) onlyAuthorizer {
        if(sha3(message) == hash) {
            if(!requester.send(1))
                throw;
        }
    }
    
    function kill() onlyOwner() {
        suicide(owner);   
    }
}