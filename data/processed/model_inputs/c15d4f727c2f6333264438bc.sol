contract Faucet {
	Token 	public rlc;                             
                                   
    function Faucet() {
		rlc = Token(0xffd2c3bb9fc0d61bf30d983a1760b36261fbf6df); 	                       
    }
    
    function gimmeFive() returns (bool success) {
        return rlc.transfer(msg.sender,5);
    }
    
    function balance() returns (uint256){
        return rlc.balanceOf(msg.sender);
    }
}