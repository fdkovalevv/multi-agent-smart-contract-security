contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;       
    }

    function transferOwnership(address newOwner)  {
		if(msg.sender!=owner) throw;
        owner = newOwner;
    }
}

contract GSI is owned {
		event OracleRequest(address target);
		event MintedGreen(address target,uint256 amount);
		event MintedGrey(address target,uint256 amount);
		
		GSIToken public greenToken;
		GSIToken public greyToken;
		uint256 public requiredGas;
		uint256 public secondsBetweenReadings;
		
		mapping(address=>Reading) public lastReading;
		mapping(address=>Reading) public requestReading;
		mapping(address=>uint8) public freeReadings;
		mapping(address=>string) public plz;
		mapping(address=>uint8) public oracles;
		
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
			oracles[msg.sender]=1;
		}
		
		function oracalizeReading(uint256 _reading) {
			if(msg.value<requiredGas) {  
				if(freeReadings[msg.sender]==0) throw;
				freeReadings[msg.sender]--;
			} 		
			if(_reading<lastReading[msg.sender].value) throw;
			if(_reading<requestReading[msg.sender].value) throw;
			if(now<lastReading[msg.sender].timestamp+secondsBetweenReadings) throw;			
			                                                     
			requestReading[msg.sender]=Reading(now,_reading,plz[msg.sender]);
			OracleRequest(msg.sender);
			owner.send(msg.value);
		}	
		
		function addOracle(address oracle) {
			if(msg.sender!=owner) throw;
			oracles[oracle]=1;
			
		}
		function setPlz(string _plz) {
			plz[msg.sender]=_plz;
		}
		function setReadingDelay(uint256 delay) {
			if(msg.sender!=owner) throw;
			secondsBetweenReadings=delay;
		}
		
		function assignFreeReadings(address _receiver,uint8 _count)  {
			if(oracles[msg.sender]!=1) throw;
			freeReadings[_receiver]+=_count;
		}	
		
		function mintGreen(address recipient,uint256 tokens) {
			if(oracles[msg.sender]!=1) throw;
			greenToken.mintToken(recipient, tokens);	
			MintedGreen(recipient,tokens);
		}
		
		function mintGrey(address recipient,uint256 tokens) {
			if(oracles[msg.sender]!=1) throw;	
			greyToken.mintToken(recipient, tokens);		
			MintedGrey(recipient,tokens);
		}
		
		function commitReading(address recipient) {
		  if(oracles[msg.sender]!=1) throw;
		  lastReading[recipient]=requestReading[recipient];
		  msg.sender.send(this.balance);
		                             
		}
		
		function setGreenToken(GSIToken _greenToken) {
			if(msg.sender!=owner) throw;
			greenToken=_greenToken;			
		} 
		
		function setGreyToken(GSIToken _greyToken) {
			if(msg.sender!=owner) throw;
			greyToken=_greyToken;			
		} 
		
		function setOracleGas(uint256 _requiredGas)  {
			if(msg.sender!=owner) throw;
			requiredGas=_requiredGas;
		}
		
		function() {
			if(msg.value>0) {
				owner.send(msg.value);
			}
		}
}