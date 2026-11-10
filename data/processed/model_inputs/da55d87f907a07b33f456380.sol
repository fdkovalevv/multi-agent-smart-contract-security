contract mortal {
	address owner;
	function mortal() { owner = msg.sender; }
	function kill() { if (msg.sender == owner) suicide(owner); }
}

contract marketpayUnwiredApp is mortal {
	uint256 public countMessage;

	struct mssg {
		uint256 idMessage;
		uint256 idPrevious;
		uint256 timestamp;
		address from;
		address to;
		string message;
	}

	                                                                       
	mapping (address => mapping (uint256 => mssg)) public messagesTo;

	                                                                     
	mapping (address => mapping (uint256 => mssg)) public messagesFrom;

	                                                       
	mapping (address => uint256) public lastIdMessageTo;
	mapping (address => uint256) public lastIdMessageFrom;
	
	
	         
	event calledRefillFunds(address from, uint256 timestamp, uint256 amount);
	event faucetResult(address from, address to, string result);
	event calledSendMessage(address from, address to, uint256 timestamp);


	                                                                    
	function readYourMessageById(uint256 idMessage) constant returns (string message) {
		return messagesTo[msg.sender][idMessage].message;
	}

	                                                       
	function readSentMessageById(uint256 idMessage) constant returns (string message) {
		return messagesFrom[msg.sender][idMessage].message;
	}

	                                                                          
	function readYourMessageMetadataById(uint256 idMessage) constant returns (uint256 _idMessage, uint256 _idPrevious, uint256 _timestamp, address _from, address _to, string _message) {
		return (messagesTo[msg.sender][idMessage].idMessage, messagesTo[msg.sender][idMessage].idPrevious, messagesTo[msg.sender][idMessage].timestamp, messagesTo[msg.sender][idMessage].from, messagesTo[msg.sender][idMessage].to, messagesTo[msg.sender][idMessage].message);
	}

	                                                                 
	function readSentMessageMetadataById(uint256 idMessage) constant returns (uint256 _idMessage, uint256 _idPrevious, uint256 _timestamp, address _from, address _to, string _message) {
		return (messagesFrom[msg.sender][idMessage].idMessage, messagesFrom[msg.sender][idMessage].idPrevious, messagesFrom[msg.sender][idMessage].timestamp, messagesFrom[msg.sender][idMessage].from, messagesFrom[msg.sender][idMessage].to, messagesFrom[msg.sender][idMessage].message);
	}

	                                                 
	function readYourLastMessage() constant returns (string message) {
		return readYourMessageById(lastIdMessageTo[msg.sender]);
	}

	                                    
	function readSentLastMessage() constant returns (string message) {
		return readSentMessageById(lastIdMessageFrom[msg.sender]);
	}

	                                    
	function sendMessage(address to, string message) {
		if (countMessage == 0) countMessage = 1;                              
		messagesTo[to][countMessage].idMessage = countMessage;
		messagesTo[to][countMessage].idPrevious = lastIdMessageTo[to];
		messagesTo[to][countMessage].timestamp = timestamp();
		messagesTo[to][countMessage].from = msg.sender;
		messagesTo[to][countMessage].to = to;
		messagesTo[to][countMessage].message = message;

		messagesFrom[msg.sender][countMessage].idMessage = countMessage;
		messagesFrom[msg.sender][countMessage].idPrevious = lastIdMessageFrom[msg.sender];
		messagesFrom[msg.sender][countMessage].timestamp = timestamp();
		messagesFrom[msg.sender][countMessage].from = msg.sender;
		messagesFrom[msg.sender][countMessage].to = to;
		messagesFrom[msg.sender][countMessage].message = message;

		lastIdMessageTo[to] = countMessage;
		lastIdMessageFrom[msg.sender] = countMessage;
		
		countMessage++;
		calledSendMessage(msg.sender, to, timestamp());       
	}

	                                                               
	function whoAmI() constant returns (address) {
		return msg.sender;
	}

	                                                     
	function timestamp() constant returns (uint256) {
		return block.timestamp;
	}

	                                             
	function refillFunds() payable returns (uint256) {
		calledRefillFunds(msg.sender, timestamp(), msg.value);       

		return 1;
	}
	
	                                                          
	function sendFundsToFriend(address to) {
		if (to.balance > 1000000000000000000) {
			faucetResult(msg.sender, to, 'Friends balance higher than 1 Ether');
			throw;                                                               
		}
		if (this.balance < 1000000000000000000) {
			faucetResult(msg.sender, to, 'Faucets balance lower than 1 Ether');
			throw;                                                            
		}
		bool dummy = to.send(1000000000000000000);
		faucetResult(msg.sender, to, 'Sent 1 Ether to friends account');
	}
}