contract SafeMath {
             
  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

contract Investment is SafeMath{
	Crowdsale public ico;
	address[] public investors;
	mapping(address => uint) public balanceOf;


	                                                             
	function Investment(){
		ico = Crowdsale(0xf66ca56fc0cf7b5d9918349150026be80b327892);
	}

	                          
	function() payable{
		if(!isInvestor(msg.sender)){
			investors.push(msg.sender);
		}
		balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], msg.value);
	}

	                                              
	function isInvestor(address who) returns (bool){
		for(uint i = 0; i< investors.length; i++)
			if(investors[i] == who)
				return true;
		return false;
	}

	                                                                      
                                                                                   
                                                                                                                           
	function buyTokens(uint from, uint to){
		uint amount;
		if(to>investors.length)
			to = investors.length;
		for(uint i = from; i < to; i++){
			if(balanceOf[investors[i]]>0){
				amount = balanceOf[investors[i]];
				delete balanceOf[investors[i]];
				ico.invest.value(amount)(investors[i]);
			}
		}
	}

	                                                                                            
                                                 
	function withdraw(){
		uint amount = balanceOf[msg.sender];
		balanceOf[msg.sender] = 0;
		if(!msg.sender.send(amount))
			balanceOf[msg.sender] = amount;
	}

	                                       
	function getNumInvestors() constant returns(uint){
		return investors.length;
	}

}