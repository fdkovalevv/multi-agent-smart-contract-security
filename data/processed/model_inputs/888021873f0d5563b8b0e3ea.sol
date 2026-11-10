contract TestRegistrar {
    uint constant registrationPeriod = 4 weeks;
    
    AbstractENS public ens;
    bytes32 public rootNode;
    mapping(bytes32=>uint) public expiryTimes;
    
       
                   
                                                      
                                                            
       
    function TestRegistrar(address ensAddr, bytes32 node) {
        ens = AbstractENS(ensAddr);
        rootNode = node;
    }

       
                                                      
                                                        
                                                 
           
    function register(bytes32 subnode, address owner) {
        if(expiryTimes[subnode] >= now)
            throw;

        expiryTimes[subnode] = now + registrationPeriod;
        ens.setSubnodeOwner(rootNode, subnode, owner);
    }
}