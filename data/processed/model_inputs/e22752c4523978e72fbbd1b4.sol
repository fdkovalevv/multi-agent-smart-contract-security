contract LitmusCrowdsale {
	using SafeMath for uint256;
	uint256 public weiRaised = 0;
	uint256 public rate = 1000000000000000;
	uint256 public goal = 1000000000000000000000;
	uint256 public cap = 5000000000000000000000;
	
	uint256 public startTime =  1506556800;
	uint256 public bonusTime = 1507248000;
	uint256 public endTime =  1509235200;

	bool public fundersClaimed = false;
	address public issuer;
	
    ERC20 public token;
	mapping (address => uint256) contributions;
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
	
	function LitmusCrowdsale (){	
	issuer = msg.sender;
	token = createTokenContract();
	}
	
	modifier ifIssuer(){
    require(issuer == msg.sender);
    _;
    }

    function createTokenContract() internal returns (ERC20) {
    return new ERC20();
	}
    
	function timeElapsed() internal constant returns (bool) {
	bool assertTime = now > endTime;
	return assertTime;
	}
	
	
    function goalReached() internal constant returns (bool) {
    return weiRaised >= goal;
	}
	
	function icoFunded() internal constant returns (bool) {
    bool softCap = goalReached() && timeElapsed();
	bool hardCap = weiRaised >= cap;
	return softCap || hardCap;
	}
	
	function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
	bool withinCap = weiRaised.add(msg.value) <= cap;
    return withinPeriod && withinCap;
	}
	
	function accruedBonus(uint256 senderWei, uint256 _tokens) internal constant returns (uint256 bonus) {
    require(_tokens != 0);
	if (now <= bonusTime || senderWei >= 1 ether) {
		return _tokens.div(20);
		}
		return 0;
	}
	
	function buyTokens() public payable {
    require(msg.value >= 50 finney);
	require(validPurchase());
	address backer =  msg.sender;
    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.div(rate);
	tokens = tokens.add(accruedBonus(weiAmount,tokens));
    weiRaised = weiRaised.add(weiAmount);
    token.allocate(backer, tokens);
	contributions[backer] = contributions[backer].add(weiAmount);
	TokenPurchase(msg.sender, msg.sender, weiAmount, tokens);
    }
	
	function claimRefund() public {
	require(!goalReached() && timeElapsed());		
	address investor = msg.sender;
	uint256 invested = contributions[investor];
	require(invested > 0);
	contributions[investor] = 0;
	investor.transfer(invested);
	}
	
	function finalise() ifIssuer public {		
	require(icoFunded());
	issuer.transfer(this.balance);
	}
  
	function init() ifIssuer public {	
	require(!fundersClaimed);
	fundersClaimed = true;
	token.allocate(issuer, 5750000);
	}
	
	function mop() ifIssuer public {
	require(now > endTime + 31 days);
	issuer.transfer(this.balance);
	} 
    
    function verifyYourBalance(address _YourWallet) public constant returns (uint256 balance) {
	return token.balanceOf(_YourWallet);
    }

	function () payable {
    buyTokens();
	}

}