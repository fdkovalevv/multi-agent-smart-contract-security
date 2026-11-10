contract disable_stuffyWallet{
	address public owner;

	constructor() public{
		owner = msg.sender;
	}

	function deposit() external payable{
		require(msg.value > 0);
	}

	                                                                                        
	function zero_withdraw() external{
		require(address(this).balance == 0);
		msg.sender.transfer(address(this).balance);
	}
}