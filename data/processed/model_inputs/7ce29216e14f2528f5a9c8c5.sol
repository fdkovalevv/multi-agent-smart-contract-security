contract VerifySig {
    
    function check(bytes32 data, uint8 v, bytes32 r, bytes32 s) constant returns(address) 
    {
      return ecrecover(data, v, r, s);
    }
    
    function checkSig(bytes32 hash, bytes sig) constant returns(address) 
    {
                                                                 
        
        uint8   v;
        bytes32 r;
        bytes32 s;
                       
        
        assembly {
                                                    
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := and(mload(add(sig, 65)), 255)
        }
    
                                                              
        if (v < 27)
            v += 27;
    
        return ecrecover(hash, v, r, s) ;
    }
}