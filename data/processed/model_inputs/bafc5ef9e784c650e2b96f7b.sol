contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


     
                                                                                    
     
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

     
                                                                                
     
  modifier whenPaused() {
    require(paused);
    _;
  }

     
                                                              
     
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

     
                                                                 
     
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract BitkomSale is Pausable {

    using SafeMath for uint256;

    uint public constant RATE = 2500;                                            
    uint public constant GAS_LIMIT_IN_WEI = 50000000000 wei;
    uint public constant MIN_CONTRIBUTION = 0.1 * 1 ether;                                                          
    uint public constant TOKEN_HARDCAP = 33500000 * 1 ether;                                                          

    bool public fundingCapReached = false;                                 
    bool public tokenHardcapReached = false;                                   
    bool public softcapReached = false;                                
    bool public saleClosed = false;                                      
    bool private rentrancy_lock = false;                                                     

    uint public fundingCap;                                                                     
    uint256 public soldTokens = 0;                                   
    uint256 public softCapInTokens = 1600000 * 1 ether;                                          

    uint public weiRaised;                                         
    uint public weiRefunded;                                           

    uint public startTime;                                                     
    uint public deadline;                                                               

    address public beneficiary;                                                                    

    BitkomToken public tokenReward;                            

    mapping (address => uint256) public balanceOf;                                                                      
    mapping (address => bool) refunded;                                                   

             
    event CapReached(address _beneficiary, uint _weiRaised);
    event SoftcapReached(address _beneficiary, uint _weiRaised);
    event FundTransfer(address _backer, uint _amount, bool _isContribution);
    event Refunded(address indexed holder, uint256 amount);

                
    modifier beforeDeadline()   { require (currentTime() < deadline); _; }
    modifier afterDeadline()    { require (currentTime() >= deadline); _; }
    modifier afterStartTime()   { require (currentTime() >= startTime); _; }
    modifier saleNotClosed()    { require (!saleClosed); _; }
    modifier softCapRaised()    { require (softcapReached); _; }

    modifier nonReentrant() {
        require(!rentrancy_lock);
        rentrancy_lock = true;
        _;
        rentrancy_lock = false;
    }

       
                                                         
      
                                                                       
                                                                              
                                                                           
                                                                                 
                                                                           
       
    function BitkomSale(
        address ifSuccessfulSendTo,
        uint256 fundingCapInEthers,
        uint256 start,
        uint256 durationInDays,
        address addressOfTokenUsedAsReward
    ) public 
    {      
        require(ifSuccessfulSendTo != address(0) && ifSuccessfulSendTo != address(this));
        require(addressOfTokenUsedAsReward != address(0) && addressOfTokenUsedAsReward != address(this));
        require(durationInDays > 0);
        beneficiary = ifSuccessfulSendTo;
        fundingCap = fundingCapInEthers * 1 ether;
        startTime = start;
        deadline = start + (durationInDays * 1 days);
        tokenReward = BitkomToken(addressOfTokenUsedAsReward);
    }


    function () public payable {
        buy();
    }


    function buy()
        payable
        public
        whenNotPaused
        beforeDeadline
        afterStartTime
        saleNotClosed
        nonReentrant
    {
        uint amount = msg.value;
        require(amount >= MIN_CONTRIBUTION);

        weiRaised = weiRaised.add(amount);

                                           
                                                                      
        if (weiRaised > fundingCap) {
            uint overflow = weiRaised.sub(fundingCap);
            amount = amount.sub(overflow);
            weiRaised = fundingCap;
                                                 
            msg.sender.transfer(overflow);
        }

                                   
        uint256 bonus = calculateBonus();

                                              
        uint256 tokensAmountForUser = (amount.mul(RATE)).mul(bonus);

        soldTokens = soldTokens.add(tokensAmountForUser);

                                                                        
        if (soldTokens > TOKEN_HARDCAP) {
            uint256 overflowInTokens = soldTokens.sub(TOKEN_HARDCAP);
            uint256 overflowInWei = (overflowInTokens.div(bonus)).div(RATE);
            amount = amount.sub(overflowInWei);
            weiRaised = weiRaised.sub(overflowInWei);
                                                 
            msg.sender.transfer(overflowInWei);

                                      
            tokensAmountForUser = tokensAmountForUser.sub(overflowInTokens);

            soldTokens = TOKEN_HARDCAP;
        }


                                                                                     
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);

                                                                      
        if (!tokenReward.transferFrom(tokenReward.owner(), msg.sender, tokensAmountForUser)) {
            revert();
        }

        FundTransfer(msg.sender, amount, true);

        if (soldTokens >= softCapInTokens && !softcapReached) {
            softcapReached = true;
            SoftcapReached(beneficiary, weiRaised);
        }

        checkCaps();
    }

       
                                                         
       
    function terminate() external onlyOwner {
        saleClosed = true;
    }


       
                                                                  
                                                                 
                                                                
                                                               
       
    function ownerSafeWithdrawal() external onlyOwner softCapRaised nonReentrant {
        uint balanceToSend = this.balance;
        beneficiary.transfer(balanceToSend);
        FundTransfer(beneficiary, balanceToSend, false);
    }

       
                                                                    
                                                         
       
    function checkCaps() internal {
        if (weiRaised == fundingCap) {
                                                        
            fundingCapReached = true;
            saleClosed = true;
            CapReached(beneficiary, weiRaised);
        }
        if (soldTokens == TOKEN_HARDCAP) {
                                                        
            tokenHardcapReached = true;
            saleClosed = true;
            CapReached(beneficiary, weiRaised);
        }
    }

       
                                
      
    function currentTime() internal constant returns (uint _currentTime) {
        return now;
    }

       
                               
      
    function calculateBonus() internal constant returns (uint) {
        if (soldTokens >= 0 && soldTokens <= 10000000 * 1 ether) {
            return 4;
        } else if (soldTokens > 10000000 * 1 ether && soldTokens <= 20000000 * 1 ether) {
            return 3;
        } else if (soldTokens > 20000000 * 1 ether && soldTokens <= 30000000 * 1 ether) {
            return 2;
        } else {
            return 1;
        }
    }

    function refund() external afterDeadline {
        require(!softcapReached);
        require(refunded[msg.sender] == false);

        uint256 balance = this.balanceOf(msg.sender);
        require(balance > 0);

        uint refund = balance;
        if (refund > this.balance) {
            refund = this.balance;
        }

        if (!msg.sender.send(refund)) {
            revert();
        }
        refunded[msg.sender] = true;
        weiRefunded = weiRefunded.add(refund);
        Refunded(msg.sender, refund);
    }
}