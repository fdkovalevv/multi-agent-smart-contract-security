library Math {
                                                                
                             
                              
                                      
    function safeToAdd(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a + b >= a;
    }

                                                                        
                        
                           
                                       
    function safeToSub(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return a >= b;
    }

                                                                    
                             
                              
                                      
    function safeToMul(uint a, uint b)
        public
        constant
        returns (bool)
    {
        return b == 0 || a * b / b == a;
    }

                                                
                             
                              
                   
    function add(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToAdd(a, b));
        return a + b;
    }

                                                       
                        
                           
                          
    function sub(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToSub(a, b));
        return a - b;
    }

                                                    
                             
                              
                       
    function mul(uint a, uint b)
        public
        constant
        returns (uint)
    {
        require(safeToMul(a, b));
        return a * b;
    }
}