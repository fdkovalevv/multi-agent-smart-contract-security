contract SafeMath {
             

  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

contract EdgelessToken is SafeMath {
                                       
    string public standard = 'ERC20';
    string public name = 'Edgeless';
    string public symbol = 'EDG';
    uint8 public decimals = 0;
    uint256 public totalSupply;
    uint256 public currentInterval = 1;
    uint256 public intervalLength = 30 days;
    address public owner;
                                                               
    uint256 public startTime = 1490112000;
                                                  
    bool burned;

                                                 
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

                                                                                
    mapping(address => mapping(uint256=>uint256)) public locked;

                                                                                  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Lock(address indexed owner, uint256 interval, uint256 value);

                                                                                      
                                                                             
    function EdgelessToken() {
        owner = 0x003230BBE64eccD66f62913679C8966Cf9F41166;
        balanceOf[owner] = 500000000;                                                  
        totalSupply = 500000000;                                         
        for(uint8 i = 1; i < 13; i++)		                                                                
        	locked[owner][i] = 50000000;
    }

                                                     
    function transfer(address _to, uint256 _value) returns (bool success){
        if (now < startTime) throw;                                         
        if (locked[msg.sender][getInterval()] >= balanceOf[msg.sender] || balanceOf[msg.sender]-locked[msg.sender][getInterval()] < _value) throw;                                    
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender],_value);                                                
        balanceOf[_to] = safeAdd(balanceOf[_to],_value);                                                            
        Transfer(msg.sender, _to, _value);                                                                           
        return true;
    }

                                                                              
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


                                                                         
                                                            
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (now < startTime && _from!=owner) throw;                                         
        if (locked[_from][getInterval()] >= balanceOf[_from] || balanceOf[_from]-locked[_from][getInterval()] < _value) throw;                                      
        var _allowance = allowance[_from][msg.sender];
        balanceOf[_from] = safeSub(balanceOf[_from],_value);                            
        balanceOf[_to] = safeAdd(balanceOf[_to],_value);                                     
        allowance[_from][msg.sender] = safeSub(_allowance,_value);
        Transfer(_from, _to, _value);
        return true;
    }

                                                                                               
                                         
    function lock(address holder, uint256 _value) returns (bool success) {
        if(holder==msg.sender||holder==tx.origin){
			uint ci = getInterval();
			uint holderLock = locked[holder][ci];
            locked[holder][ci] = safeAdd(holderLock,_value);
            Lock(holder, ci, _value);
            return true;
        }
    }

                                                            
                                                              
    function getInterval() returns (uint256 interval){
        if (now > safeAdd(safeMul(currentInterval, intervalLength), startTime)) {
            currentInterval = (now - startTime) / intervalLength + 1;
        }
        return currentInterval;
    }

                                                                                                                          
                                           
                                                                                                                      
                                                                               
    function burn(){
    	                                                          
    	if(!burned && now>startTime){
    		uint difference = safeSub(balanceOf[owner], 60000000);                            
    		balanceOf[owner] = 60000000;
    		totalSupply = safeSub(totalSupply, difference);
    		burned = true;
    	}
    }

}