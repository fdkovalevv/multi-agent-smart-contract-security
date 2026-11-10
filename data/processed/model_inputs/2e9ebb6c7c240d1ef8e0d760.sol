contract Crowdsale {

  	struct BackerETH {
	  uint weiReceived;	                      
	  uint rlcToSend;  	                                                
	}

  	struct BackerBTC {
	  string btc_address;                             
	  uint satoshiReceived;	                      
	  uint rlcToSend;   	                                                
	}

	Token 	public RLC;                                  
	address public owner;                                      
	address public multisigETH;                                               
	uint public RLCPerETH;                              
	uint public RLCPerBTC;                              
	uint public receivedETH;                             
	uint public receivedBTC;                             
	uint public RLCSentToETH;                                            
	uint public RLCSentToBTC;                                            
	uint public startBlock;                             
	uint public endBlock;                             
	uint public minCap;                                               
	uint public maxCap;                                               
	bool public minCapReached;                             
	bool public maxCapReached;                             
	uint public minInvestETH;                              
	uint public minInvestBTC;                              

	mapping(address => BackerETH) public backersETH;                                          
	mapping(address => BackerBTC) public backersBTC;                                                

                                                                          
	modifier onlyBy(address a){
	    if (msg.sender != a) throw;  
	    _;
	}

	event ETHReceived(address);
	event BTCReceived(string,address);

	                               
	function Crowdsale() {
		
	                               
	  owner = msg.sender;
	  RLC = Token(0x0a8f269d52fad5f0f6297a264f48cbb290c68130); 	                       
	  multisigETH = 0x8cd6B3D8713df6aA35894c8beA200c27Ebe92550;
	  owner = msg.sender;
	  minInvestETH = 100 finney;                
	  minInvestBTC = 100000;                    
	  startBlock = 1 ;                            
	  endBlock =  1578450;                                             
	  RLCPerBTC = 50000;                                                      
	  RLCPerETH = 5000;                  
	  minCap=10;
	}

	                                                          
	function(){
	  receiveETH(msg.sender);
	}
	
	function receiveETH(address beneficiary) payable{
	                                                    
	  if (msg.value > minInvestETH) throw;

	                                       
	  if ((now > endBlock) || (now < startBlock )) throw;  

	                                     
	  uint rlcToSend = bonus((msg.value*RLCPerETH)/(1 ether));
	  
	                     
	  BackerETH backer = backersETH[beneficiary];
	  backer.weiReceived += msg.value;
	  
	  if (!transferRLC(beneficiary, rlcToSend)) throw;     
	  
	  receivedETH += msg.value;                                                                 
	  RLCSentToETH += rlcToSend;
	  minCapReached = (RLCSentToETH + RLCSentToBTC) > minCap;

	  ETHReceived(beneficiary);
	  
	}

	                                                                       
	function withdrawETH(address to, uint amount) onlyBy (owner){
	  if (!minCapReached) throw;
	  var r = to.send(amount);
	}

	                                                                       
	function withdrawRLC(address to, uint amount) onlyBy(owner){
	  if (!minCapReached) throw;
	  RLC.transfer(to, amount);
	}

	  
                        
   
   
	
	function bonus(uint amount) returns (uint) {
	  if (now < (startBlock + 10 days)) return (amount + amount/5);
	  if (now < startBlock + 20 days) return (amount + amount/10);
	  return amount;
	}
	  
                          
                                                                                      
    
	
	function transferRLC(address to, uint amount) internal returns (bool) {
	  return RLC.transfer(to, amount);
	}
}