contract testing {
  mapping (address => uint256) public balanceOf;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event LogB(bytes32 h);

	  
  	function buy() payable returns (uint amount){
        amount = msg.value ;                                             
        if (balanceOf[this] < amount) throw;                                                 
        balanceOf[msg.sender] += amount;                                                        
        balanceOf[this] -= amount;                                                                  
        Transfer(this, msg.sender, amount);                                                         
        return amount;                                                                 
    }
	  

}