contract mortal {
	address owner;
	
	function mortal() { owner = msg.sender; }
	
	function kill() { if (msg.sender == owner) suicide(owner); }
}

contract marketPayEscrow is mortal {

	       
	struct escrow {
		address buyer;
		address seller;
		address thirdParty;
		address recipient;
		uint amount;
		uint revokedByBuyer;
		uint revokedBySeller;
		uint revokedByThirdParty;
		uint releasedByBuyer;
		uint releasedBySeller;
		uint releasedByThirdParty;
		                                                                                                    
		uint status;                                                           
	}
	mapping (uint => escrow) escrows;
	uint public numEscrows = 0;

	         
	event escrowStart(address buyer, address seller, address thirdParty);
	event escrowRevoke(address recipient, uint amount);
	event escrowRelease(address recipient, uint amount);

	            
	function queryStatus(uint escrowId) constant returns (uint status) {
		escrow e = escrows[escrowId];
		return e.status;
	}
	
	function start(address seller, address thirdParty) returns (uint) {
		uint escrowId = numEscrows;
		numEscrows++;
		escrow memory e;
		e.thirdParty = thirdParty;
		e.seller = seller;
		e.buyer = msg.sender;
		e.amount = msg.value;
		e.recipient = seller;
		e.status = 1;           
		escrows[escrowId] = e;
		
		escrowStart(e.buyer, e.seller, e.thirdParty);       
		
		return escrowId;
	}
	
	function revoke(uint escrowId) returns (uint amount) {
		escrow e = escrows[escrowId];
		if (e.status != 1) {           
			                                                                                       
			return 0;
		}
		if (msg.sender == e.buyer) {
				e.revokedByBuyer = 1;
		} else if (msg.sender == e.thirdParty) {
				e.revokedByThirdParty = 1;
		} else if (msg.sender == e.seller) {
				e.revokedBySeller = 1;
		} else {
			                                                                                   
			return 0;
		}
		
		if (e.revokedByBuyer + e.revokedByThirdParty + e.revokedBySeller >= 2) {
			bool kk = e.buyer.send(e.amount);
			e.status = 2;           
			                                                                                                                                    
			escrowRevoke(e.buyer, e.amount);       
			return e.amount;
		} else {
			                                                                                                                       
		}
		return 0;
	}

	function release(uint escrowId) returns (uint amount) {
		escrow e = escrows[escrowId];
		if (e.status != 1) {           
			                                                                
			return 0;
		}
		if (msg.sender == e.buyer) {
				e.releasedByBuyer = 1;
		} else if (msg.sender == e.thirdParty) {
				e.releasedByThirdParty = 1;
		} else if (msg.sender == e.seller) {
				e.releasedBySeller = 1;
		} else {
			                                                                                   
			return 0;
		}
		
		if (e.releasedByBuyer + e.releasedByThirdParty + e.releasedBySeller >= 2) {
			bool kk = e.seller.send(e.amount);
			e.status = 3;        
			                                                                                                                                      
			escrowRelease(e.seller, e.amount);       
			return e.amount;
		} else {
			                                                                                                                       
		}
		return 0;
	}
}