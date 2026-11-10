contract PasswordMarket {
	address public owner;
	uint128 feeratemul = 1; uint128 feeratediv = 20;                                      
	uint public minRewardAmount = 0.01 ether;             
	
	struct Offer2 {
		uint weiAmount;
		address who;
  	}
	mapping (bytes32 => Offer2) public dHashes;

	         
	event hashSubmitted(address indexed author, bytes32 indexed hash, uint amount);
	event hashResolved(address indexed author, bytes32 indexed hash, string s, uint amount);

	function PasswordMarket() {
    	owner = msg.sender;
    }
	
	function isHashHere(bytes32 hash) internal returns(bool) {
		return !(dHashes[hash].weiAmount==0);
	}
	
	function submitHash(bytes32 h) payable {
		if((!isHashHere(h))&&(msg.value>=minRewardAmount)) { 
			dHashes[h].who = msg.sender;
			dHashes[h].weiAmount = msg.value;
			hashSubmitted(msg.sender, h, msg.value);
			             
                            
                      
                     
		}
		else {
			                          
			throw;
		}
	}
	
	function submitAnswer(string s) {
		bytes32 hash = sha256(s);
		uint reward = dHashes[hash].weiAmount;
		if(reward>0) {
		    uint fees = reward*feeratemul/feeratediv;
			uint netreward = reward-fees;
			if(!msg.sender.send(netreward)) throw;                                            
			if(!owner.send(fees)) throw;                                           
			hashResolved(msg.sender, hash, s, netreward);
			delete dHashes[hash];
		}
		else {
			throw;
		}
	}

	                 

	                              
	function () payable {
		                                                     
		payOwner(msg.value);
	}

	                 

	modifier onlyOwner() {
		if(msg.sender != owner) throw;                        
		_;
    }
    
    function payOwner(uint amount) private onlyOwner() {
        if(!owner.send(amount)) throw;             
    }

    function modifyFees(uint128 frm, uint128 frd) onlyOwner() {
    	if((frd!=0)&&(frm<=frd)) {
    		feeratemul = frm; feeratediv = frd;
    	}
    }

	function withdrawFunds() onlyOwner() {
		payOwner(this.balance);
	}

	function autokill() onlyOwner() {
        suicide(owner);
	}
}