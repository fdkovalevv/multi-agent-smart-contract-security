contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Crowdsale {


  using SafeMath for uint256;

                         
  MintableToken public token;

                                                                            
  uint256 public startTime;
  uint256 public endTime;

                                      
  address public wallet;

                                              
  uint256 public rate;

                                  
  uint256 public weiRaised;

     
                                     
                                             
                                          
                                        
                                             
     
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function Crowdsale (uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract(_token);
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

                                  
                                                                         
  function createTokenContract(address tokenAddress) internal returns (MintableToken) {
    return MintableToken(tokenAddress);
  }


                                                
  function () payable {
    buyTokens(msg.sender);
  }

                                      
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

                                           
    uint256 tokens = weiAmount.mul(rate);

                   
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

                                             
                                                         
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

                                                   
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

                                              
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}

contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

     
                                                                            
                                                      
     
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

     
                                                                              
                                                                            
                       
     
  function finalization() internal {
  }
}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

                                                              
                                                    
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

                                                   
                                              
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

contract FortitudeRanchCrowdsale is FinalizableCrowdsale, CappedCrowdsale {

	function FortitudeRanchCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token)
		FinalizableCrowdsale()
		CappedCrowdsale(150000000000000000000000)
		Crowdsale(_startTime, _endTime, _rate, _wallet, _token)
	{
	}
	function buyTokens(address beneficiary) public payable {
	    require(beneficiary != 0x0);
	    require(validPurchase());

	    uint256 weiAmount = msg.value;

	                                           
	    if(now < (startTime + 1 days)){
	    	uint256 discountRate = rate.mul(12000000);
	    	discountRate = discountRate.div(10000);
	    	uint256 tokens = weiAmount.mul(discountRate).div(1000 ether);
	    } else { 
	    	 tokens = (weiAmount.mul(rate)).div(1 ether);
		}
	                   
	    weiRaised = weiRaised.add(weiAmount);

	    token.mint(beneficiary, tokens);
	    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

	    forwardFunds();
	}
	function offChainMint(address beneficiary, uint256 tokenAmount)
	onlyOwner
	{
	    require(beneficiary != 0x0);
	    bool withinCap = token.totalSupply().add(tokenAmount) <= cap;
	    require(withinCap);
    	token.mint(beneficiary, tokenAmount);
    	TokenPurchase(msg.sender, beneficiary, 0, tokenAmount);


	}
	function validPurchase() internal constant returns (bool) {
		require(msg.value >= 100000000000000000);
	    if(now < (startTime + 1 days)){
	    	uint256 discountRate = rate.mul(12000000);
	    	discountRate = discountRate.div(10000);
	    	uint256 tokens = (msg.value).mul(discountRate).div(1000 ether);
	    } else { 
	    	 tokens = (msg.value.mul(rate)).div(1 ether);
		}
		bool withinCap = token.totalSupply().add(tokens) <= cap;
		return super.validPurchase() && withinCap;

	}
	function hasEnded() public constant returns (bool) {
		bool capReached = token.totalSupply() >= cap;
		return super.hasEnded() || capReached;
	}
	function finalization() internal {
		uint256 tokensAmount = token.totalSupply();
		tokensAmount = tokensAmount.mul(2);
		tokensAmount = tokensAmount.div(10);
		token.mint(0xE746Bb9d6Db2eBBF02c12E2f64D0dfa155377895, tokensAmount);
		token.finishMinting();

		super.finalization();


	}

}