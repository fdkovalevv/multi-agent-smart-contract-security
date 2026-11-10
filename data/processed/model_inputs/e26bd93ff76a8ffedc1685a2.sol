library SafeMathLib {
                                                                                             
                                                 
                                                     
    function safeAdd(uint a, uint b) returns (uint) {
        if (a + b > a) {
            return a + b;
        } else {
            throw;
        }
    }

                                                                                      
                                        
                                         
    function safeSub(uint a, uint b) returns (uint) {
        if (b <= a) {
            return a - b;
        } else {
            throw;
        }
    }
}