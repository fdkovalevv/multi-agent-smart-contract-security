contract MyReplaySafeProxy {
    
    address eth_target = 0x447F7556C8D2E5281438358087DdD368B6bCb824; 
    address ethc_target = 0xCd76f273d307551016452724241EA3C1775270a2;

	address public target;
	
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);
    
    function MyReplaySafeProxy () {
			if (amIOnTheFork.forked())
				target =  eth_target;
			else
				target =  ethc_target;
    }

    function() {
        if(!target.send(msg.value))
            throw;
    }
}