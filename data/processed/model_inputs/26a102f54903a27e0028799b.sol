contract Registry {
    mapping (address => bytes32) public names;
    mapping (bytes32 => address) public addresses;

    event LogNameChanged(address indexed who, bytes32 indexed name);

    function setName(bytes32 name) returns (bool successful) {
        if (name != 0                                                  
            && addresses[name] != 0                        
            && addresses[name] != msg.sender) {                                      
                            
            throw;
        }
        if (names[msg.sender] != "") {                                           
        	addresses[names[msg.sender]] = 0;                                 
        }
        names[msg.sender] = name;
        if (name != 0) {
            addresses[name] = msg.sender;
        }
        LogNameChanged(msg.sender, name);
        return true;
    }
}