contract PublicResolver {
    AbstractENS ens;
    mapping(bytes32=>address) addresses;

    modifier only_owner(bytes32 node) {
        if(ens.owner(node) != msg.sender) throw;
        _;
    }

       
                   
                                                 
       
    function PublicResolver(address ensAddr) {
        ens = AbstractENS(ensAddr);
    }

       
                         
       
    function() {
        throw;
    }

       
                                                                        
                                         
                                                                
                                                                             
                             
       
    function has(bytes32 node, bytes32 kind) constant returns (bool) {
        return (kind == "addr" && addresses[node] != 0);
    }
    
       
                                                       
                                         
                                      
       
    function addr(bytes32 node) constant returns (address ret) {
        ret = addresses[node];
        if(ret == 0)
            throw;
    }

       
                                                    
                                                                        
                                      
                                      
       
    function setAddr(bytes32 node, address addr) only_owner(node) {
        addresses[node] = addr;
    }
}