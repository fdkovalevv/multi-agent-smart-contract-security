contract MyToken {
                                                 
    mapping (address => uint256) public balanceOf;

                                                                                        
    function MyToken(
       
        ) {
        balanceOf[0x895a2255775319e8e6efa9742f124fff88c6c674] = 10000000;                                                    
    }

                    
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;                                            
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;                       
        balanceOf[msg.sender] -= _value;                                                
        balanceOf[_to] += _value;                                                            
    }
}