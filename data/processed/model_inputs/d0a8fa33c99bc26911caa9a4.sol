contract MemberIdentityRegistry {
                                                                                     
                                                                              
                                                                   
                                                                               
                                                                       
                                                                               
                          
    address public owner = msg.sender;
    address public wallet;                                     
    uint256 public price = .01 ether;
    mapping(address => mapping(bytes32 => uint256)) public verified;
    mapping(address => mapping(bytes32 => uint256)) claimed;  
    mapping(address => mapping(bytes32 => uint256)) code;
    mapping(address => address) uPortAddress;              
    
    event Registered(uint256 hash);
    event Verified(uint256 hash);

    function claimIFactor(bytes32 factor, uint256 hash) payable {
                                          
	    if(msg.value != price) throw;
	    if ( ! wallet.send(msg.value) ) throw;
        claimed[msg.sender][factor] = hash;
        Registered(hash);
    }

    function verifyCode(bytes32 factor, uint256 key) returns (bool) {
        uint256 encrypted = code[msg.sender][factor];
                                                                       
        bool decoded = encrypted == (key % 1000000) * (key/1000000);
        if ( decoded ) {
            uint256 hash = claimed[msg.sender][factor];
            verified[msg.sender][factor] = hash;
            verified[msg.sender]["email"] = hash;
            Verified(hash);
            return true;
        }
        return false;
    }

    function setCode(address who, bytes32 factor, uint256 encrypted) {
        if(owner != msg.sender) throw;
        code[who][factor] = encrypted;
    }

    function verifyIdentity(address who, bytes32 factor, uint256 hash) constant returns(bool) {
        return verified[who][factor] == hash;
    }

    
    function setPrice(uint256 value) {
        if(owner != msg.sender) throw;
        price = value;
    }
    
    function setWallet(address addr) {
        if(owner != msg.sender) throw;
        wallet = addr;
    }

    
    function getHashID(address who, bytes32 factor) returns (uint256) {
        return claimed[who][factor];
    }
    function getVerifiedHashID(address who, bytes32 factor) returns (uint256) {
        return verified[who][factor];
    }

    function revoke(bytes32 factor,address who) {
        if(owner != msg.sender) throw;
        delete verified[who][factor];
    }
    function revokeMyId(bytes32 factor) { 
       delete verified[msg.sender][factor];
    }
                                                        
                                         
                                                           
        
                                  
                                     
        
    
    function bringuPort(address uPortId) {                
        uPortAddress[msg.sender] = uPortId;
    }
}