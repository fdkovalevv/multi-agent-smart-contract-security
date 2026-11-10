contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

     
                                                                     
                                                
                                          
                                               
    
  function transferFunction(address _sender, address _to, uint256 _value) internal returns (bool) {
    require(_to != address(0));
    require(_to != address(this));
    require(_value <= balances[_sender]);

                                                              
    balances[_sender] = balances[_sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_sender, _to, _value);
    return true;
  }
  
     
                                                                            
    
  function transfer(address _to, uint256 _value) public returns (bool) {
	return transferFunction(msg.sender, _to, _value);
  }
  
     
                                                   
                                                          
                                                                           
    
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC223TokenCompatible is BasicToken {
  using SafeMath for uint256;
  
  event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);

                                                                                      
	function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) public returns (bool success) {
		require(_to != address(0));
        require(_to != address(this));
		require(_value <= balances[msg.sender]);
		                                                          
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
		if( isContract(_to) ) {
		 _to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data);
		} 
		Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	                                                                                    
	function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {
		return transfer( _to, _value, _data, "tokenFallback(address,uint256,bytes)");
	}

	                                                                                       
	function isContract(address _addr) private view returns (bool is_contract) {
		uint256 length;
		assembly {
                                                                                  
            length := extcodesize(_addr)
		}
		return (length>0);
    }
}