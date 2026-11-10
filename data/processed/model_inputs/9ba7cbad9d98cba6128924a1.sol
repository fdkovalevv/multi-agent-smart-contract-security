contract Ownable {
    
  address public owner;
 
     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }
 
     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}

contract preSale2 is Ownable {    
    using SafeMath for uint;        
    AgroTechFarmToken public token;
    bool public preSale2Finished = false;          
    address public multisig;  
    uint public rate;
    uint public tokenCap;
    uint public start;
    uint public period;
    uint public hardcap;
    address public restricted;
	uint public restrictedPercent;

    function preSale2() public {        
	    token = AgroTechFarmToken(0xa55ffAeA5c8cf32B550F663bf17d4F7b739534ff); 
		multisig = 0x227917ac3C1F192874d43031cF4D40fd40Ae6127;
		rate = 83333333333000000000; 
		tokenCap =  60000000000000000000000; 
		start = 1519430400; 
		period = 14; 
	    hardcap = 500000000000000000000;
	    restricted = 0xbcCd749ecCCee5B4898d0E38D2a536fa84Ea9Ef6;   
	    restrictedPercent = 35;
          
    }
 
    modifier saleIsOn() {
    	require(now > start && now < start + period * 1 days);
    	_;
    }
	
    modifier isUnderHardCap() {
      require(this.balance <= hardcap);
        _;
    } 


  function balancePreSale2() public constant returns (uint) {
     return this.balance;
    }


  function finishPreSale2() public onlyOwner returns (bool)  {
        if(now > start + period * 1 days || this.balance >= hardcap) {                     
         multisig.transfer(this.balance);
         preSale2Finished = true;
         return true;
         } else return false;     
      }
 
   function createTokens() public isUnderHardCap saleIsOn payable {
        uint tokens = rate.mul(msg.value).div(1 ether);      
        uint bonusTokens = tokens.mul(40).div(100);        

        
        tokens += bonusTokens;     
        token.mint(msg.sender, tokens);
       
	    uint restrictedTokens = tokens.mul(restrictedPercent).div(100); 
        token.mint(restricted, restrictedTokens);        
        
    }
 

    function() external payable {
        createTokens();
    } 
}