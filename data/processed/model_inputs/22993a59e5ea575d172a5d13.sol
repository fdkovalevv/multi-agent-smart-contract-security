contract Controlled {
                                                                               
                                      
    modifier onlyController { if (msg.sender != controller) throw; _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

                                                      
                                                                
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

contract SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ClitCrowdFunder is Controlled, SafeMath {

	address public creator;
    address public fundRecipient;
	
	                  
    State public state = State.Fundraising;                         
    uint public fundingGoal; 
	uint public totalRaised;
	uint public currentBalance;
	uint public issuedTokenBalance;
	uint public totalTokensIssued;
	uint public capTokenAmount;
	uint public startBlockNumber;
	uint public endBlockNumber;
	uint public eolBlockNumber;
	
	uint public firstExchangeRatePeriod;
	uint public secondExchangeRatePeriod;
	uint public thirdExchangeRatePeriod;
	uint public fourthExchangeRatePeriod;
	
	uint public firstTokenExchangeRate;
	uint public secondTokenExchangeRate;
	uint public thirdTokenExchangeRate;
	uint public fourthTokenExchangeRate;
	uint public finalTokenExchangeRate;	
	
	bool public fundingGoalReached;
	
    ClitCoinToken public exchangeToken;
	
	                                                                              
	event HardCapReached(address fundRecipient, uint amountRaised);
	event GoalReached(address fundRecipient, uint amountRaised);
	event FundTransfer(address backer, uint amount, bool isContribution);	
	event FrozenFunds(address target, bool frozen);
	event RefundPeriodStarted();

	                                                                    
	mapping(address => uint256) private balanceOf;
	mapping (address => bool) private frozenAccount;
	
	                  
    enum State {
		Fundraising,
		ExpiredRefund,
		Successful,
		Closed
	}
	
	  
                 
       

	modifier inState(State _state) {
        if (state != _state) throw;
        _;
    }
	
	                                 
	modifier atEndOfLifecycle() {
        if(!((state == State.ExpiredRefund && block.number > eolBlockNumber) || state == State.Successful)) {
            throw;
        }
        _;
    }
	
	modifier accountNotFrozen() {
        if (frozenAccount[msg.sender] == true) throw;
        _;
    }
	
    modifier minInvestment() {
                                           
      require(msg.value >= 10 ** 16);
      _;
    }
	
	modifier isStarted() {
		require(block.number >= startBlockNumber);
		_;
	}

	                                         
	function ClitCrowdFunder(
		address _fundRecipient,
		uint _delayStartHours,
		ClitCoinToken _addressOfExchangeToken
	) {
		creator = msg.sender;
		
		fundRecipient = _fundRecipient;
		fundingGoal = 7000 * 1 ether;
		capTokenAmount = 140 * 10 ** 6;
		state = State.Fundraising;
		fundingGoalReached = false;
		
		totalRaised = 0;
		currentBalance = 0;
		totalTokensIssued = 0;
		issuedTokenBalance = 0;
		
		startBlockNumber = block.number + div(mul(3600, _delayStartHours), 14);
		endBlockNumber = startBlockNumber + div(mul(3600, 1080), 14);            
		eolBlockNumber = endBlockNumber + div(mul(3600, 168), 14);                                    

		firstExchangeRatePeriod = startBlockNumber + div(mul(3600, 24), 14);                         
		secondExchangeRatePeriod = firstExchangeRatePeriod + div(mul(3600, 240), 14);                
		thirdExchangeRatePeriod = secondExchangeRatePeriod + div(mul(3600, 240), 14);                
		fourthExchangeRatePeriod = thirdExchangeRatePeriod + div(mul(3600, 240), 14);                
		
		uint _tokenExchangeRate = 1000;
		firstTokenExchangeRate = (_tokenExchangeRate + 1000);	
		secondTokenExchangeRate = (_tokenExchangeRate + 500);
		thirdTokenExchangeRate = (_tokenExchangeRate + 300);
		fourthTokenExchangeRate = (_tokenExchangeRate + 100);
		finalTokenExchangeRate = _tokenExchangeRate;
		
		exchangeToken = ClitCoinToken(_addressOfExchangeToken);
	}
	
	function freezeAccount(address target, bool freeze) onlyController {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }	
	
	function getCurrentExchangeRate(uint amount) public constant returns(uint) {
		if (block.number <= firstExchangeRatePeriod) {
			return firstTokenExchangeRate * amount / 1 ether;
		} else if (block.number <= secondExchangeRatePeriod) {
			return secondTokenExchangeRate * amount / 1 ether;
		} else if (block.number <= thirdExchangeRatePeriod) {
			return thirdTokenExchangeRate * amount / 1 ether;
		} else if (block.number <= fourthExchangeRatePeriod) {
			return fourthTokenExchangeRate * amount / 1 ether;
		} else if (block.number <= endBlockNumber) {
			return finalTokenExchangeRate * amount / 1 ether;
		}
		
		return finalTokenExchangeRate * amount / 1 ether;
	}

	function investment() public inState(State.Fundraising) isStarted accountNotFrozen minInvestment payable returns(uint)  {
		
		uint amount = msg.value;
		if (amount == 0) throw;
		
		balanceOf[msg.sender] += amount;	
		
		totalRaised += amount;
		currentBalance += amount;
						
		uint tokenAmount = getCurrentExchangeRate(amount);
		exchangeToken.generateTokens(msg.sender, tokenAmount);
		totalTokensIssued += tokenAmount;
		issuedTokenBalance += tokenAmount;
		
		FundTransfer(msg.sender, amount, true); 
		
		checkIfFundingCompleteOrExpired();
		
		return balanceOf[msg.sender];
	}

	function checkIfFundingCompleteOrExpired() {
		if (block.number > endBlockNumber || totalTokensIssued >= capTokenAmount ) {
			                     
			if (currentBalance > fundingGoal || fundingGoalReached == true) {
				state = State.Successful;
				payOut();
				
				HardCapReached(fundRecipient, totalRaised);
				
				                                         
				removeContract();

			} else  {
				state = State.ExpiredRefund;                                                          
				
				RefundPeriodStarted();
			}
		} else if (currentBalance > fundingGoal && fundingGoalReached == false) {
			                    
			fundingGoalReached = true;
			
			state = State.Successful;
			payOut();
			
			                                    
			state = State.Fundraising;
			
			                                       
			GoalReached(fundRecipient, totalRaised);
		}
	}

	function payOut() public inState(State.Successful) {
		                   
		var amount = currentBalance;
		currentBalance = 0;

		fundRecipient.transfer(amount);
		
		                                                                          
		var tokenCount = issuedTokenBalance;
		issuedTokenBalance = 0;
		
		exchangeToken.generateTokens(fundRecipient, tokenCount);		
	}

	function getRefund() public inState(State.ExpiredRefund) {	
		uint amountToRefund = balanceOf[msg.sender];
		balanceOf[msg.sender] = 0;
		
		                        
		msg.sender.transfer(amountToRefund);
		currentBalance -= amountToRefund;
		
		FundTransfer(msg.sender, amountToRefund, false);
	}
	
	function removeContract() public atEndOfLifecycle {		
		state = State.Closed;
		
		                                                             
		exchangeToken.enableTransfers(true);
		
		                                  
		exchangeToken.changeController(controller);

		selfdestruct(msg.sender);
	}
	
	                                                                                                                
	function () payable { 
		investment(); 
	}	

}