contract ReverseRegistrar {
    AbstractENS public ens;
    bytes32 public rootNode;
    
       
                       
                                                      
                                                             
       
    function ReverseRegistrar(address ensAddr, bytes32 node) {
        ens = AbstractENS(ensAddr);
        rootNode = node;
    }

       
                                                                             
                            
                                                                                 
                                                       
       
    function claim(address owner) returns (bytes32 node) {
        var label = sha3HexAddress(msg.sender);
        ens.setSubnodeOwner(rootNode, label, owner);
        return sha3(rootNode, label);
    }

       
                                                                        
                                      
                                 
       
    function node(address addr) constant returns (bytes32 ret) {
        return sha3(rootNode, sha3HexAddress(addr));
    }

       
                                                                       
                                                              
                                      
                                                                          
                             
       
    function sha3HexAddress(address addr) private returns (bytes32 ret) {
        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000
            let i := 40
        loop:
            i := sub(i, 1)
            mstore8(i, byte(and(addr, 0xf), lookup))
            addr := div(addr, 0x10)
            i := sub(i, 1)
            mstore8(i, byte(and(addr, 0xf), lookup))
            addr := div(addr, 0x10)
            jumpi(loop, i)
            ret := sha3(0, 40)
        }
    }
}