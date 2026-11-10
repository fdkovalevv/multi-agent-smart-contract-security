contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;       
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract GSI is owned {
		event OracleRequest(address target);
		
		GSIToken public greenToken;
		GSIToken public greyToken;
		uint256 public requiredGas;
		uint256 public secondsBetweenReadings;
		
		mapping(address=>Reading) public lastReading;
		mapping(address=>Reading) public requestReading;
		mapping(address=>uint8) public freeReadings;
		
		struct Reading {
			uint256 timestamp;
			uint256 value;
			string zip;
		}
		
		function GSI() {
			greenToken = new GSIToken(
							0,
							'GreenPower',
							0,
							'P+',
							this
			);
			                                         
			greyToken = new GSIToken(
							0,
							'GreyPower',
							0,
							'P-',
							this
			);							
		}
		
		function oracalizeReading(uint256 _reading,string _zip) {
			if(msg.value<requiredGas) {  
				if(freeReadings[msg.sender]==0) throw;
				freeReadings[msg.sender]--;
			} 		
			if(_reading<lastReading[msg.sender].value) throw;
			if(_reading<requestReading[msg.sender].value) throw;
			if(now<lastReading[msg.sender].timestamp+secondsBetweenReadings) throw;
			                                                     
			requestReading[msg.sender]=Reading(now,_reading,_zip);
			OracleRequest(msg.sender);
			owner.send(msg.value);
		}	
			
		function setReadingDelay(uint256 delay) onlyOwner {
			secondsBetweenReadings=delay;
		}
		
		function assignFreeReadings(address _receiver,uint8 _count) onlyOwner {
			freeReadings[_receiver]+=_count;
		}	
		
		function mintGreen(address recipient,uint256 tokens) onlyOwner {			
			greenToken.mintToken(recipient, tokens);			
		}
		
		function mintGrey(address recipient,uint256 tokens) onlyOwner {			
			greyToken.mintToken(recipient, tokens);			
		}
		
		function commitReading(address recipient,uint256 timestamp,uint256 reading,string zip) onlyOwner {			
			if(this.balance>0) {
				owner.send(this.balance);
			} 
		  lastReading[recipient]=Reading(timestamp,reading,zip);
		}
		
		function setOracleGas(uint256 _requiredGas) onlyOwner {
			requiredGas=_requiredGas;
		}
		
		function() {
			if(msg.value>0) {
				owner.send(msg.value);
			}
		}
}