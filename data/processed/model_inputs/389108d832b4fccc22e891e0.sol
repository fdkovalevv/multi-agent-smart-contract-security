contract ReverseResolver {
    AbstractENS public ens;
    mapping(bytes32=>string) names;

    modifier only_owner(bytes32 node) {
        if(ens.owner(node) != msg.sender) throw;
        _;
    }

       
                   
                                                 
       
    function ReverseResolver(address ensAddr) {
        ens = AbstractENS(ensAddr);
    }

       
                         
       
    function() {
        throw;
    }

       
                                                                        
                                         
                                                                
                                                                             
                             
       
    function has(bytes32 node, bytes32 kind) constant returns (bool) {
        return (kind == "name" && bytes(names[node]).length > 0);
    }

       
                                                                                            
                                                               
                                                                       
       
    function supportsInterface(bytes4 interfaceID) constant returns (bool) {
        return interfaceID == 0x691f3431;
    }

       
                                                    
                                         
                                   
       
    function name(bytes32 node) constant returns (string ret) {
        ret = names[node];
    }

       
                                                 
                                                                        
                                      
                                   
       
    function setName(bytes32 node, string name) only_owner(node) {
        names[node] = name;
    }
}