contract comm_channel {
	
    address owner;
    
    event content(string datainfo, uint indexed version, string indexed senderKey, string indexed recipientKey, uint amount);
    modifier onlyowner { if (msg.sender == owner) _ }
    
    function comm_channel() public { owner = msg.sender; }
    
                              
    function kill() onlyowner { suicide(owner); }

    function flush() onlyowner {
        owner.send(this.balance);
    }

    function add(string datainfo, uint version, string senderKey, string recipientKey,
                 address resendTo) {
        
                                                         
        if(msg.value > 0) {
            if(resendTo == 0) throw;
            if(!resendTo.send(msg.value)) throw;
        }
        
                             
        content(datainfo, version, senderKey, recipientKey, msg.value);
    }
}