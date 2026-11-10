contract gray_BadMarketPlace {
	mapping(address => uint256) public balance;

    function deposit() external payable {
        require(msg.value > 0);
        balance[msg.sender] = msg.value;
    }

    function withdraw() external{
    	if(balance[msg.sender] > 0)
    		msg.sender.transfer(balance[msg.sender]);
    }
}