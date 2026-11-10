contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    if (halted) throw;
    _;
  }

  modifier onlyInEmergency {
    if (!halted) throw;
    _;
  }

                                                             
  function halt() external onlyOwner {
    halted = true;
  }

                                                                     
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}

contract Crowdsale is Haltable {

  using SafeMathLib for uint;

                                
  ERC20 public token;

                                              
  PricingStrategy public pricingStrategy;

                             
  FinalizeAgent public finalizeAgent;

                                                   
  address public multisigWallet;

                                                                              
  uint public minimumFundingGoal;

                                                      
  uint public startsAt;

                                                    
  uint public endsAt;

                                                              
  uint public tokensSold = 0;

                                              
  uint public weiRaised = 0;

                                                 
  uint public investorCount = 0;

                                                                                    
  uint public loadedRefund = 0;

                                                    
  uint public weiRefunded = 0;

                                         
  bool public finalized;

                                                                 
  mapping (address => uint256) public investedAmountOf;

                                                                              
  mapping (address => uint256) public tokenAmountOf;

                                                                                                                                                                                      
  uint public ownerTestValue;

                   
    
                                                                                       
                                                    
                                
                                            
                                                                   
                                                                        
                                                                 
     
  enum State{Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}

  event Invested(address investor, uint weiAmount, uint tokenAmount);
  event Refund(address investor, uint weiAmount);

  function Crowdsale(address _token, address _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal) {

    owner = msg.sender;

    token = ERC20(_token);

    pricingStrategy = PricingStrategy(_pricingStrategy);

    multisigWallet = _multisigWallet;
    if(multisigWallet == 0) {
        throw;
    }

    if(_start == 0) {
        throw;
    }

    startsAt = _start;

    if(_end == 0) {
        throw;
    }

    endsAt = _end;

                           
    if(startsAt >= endsAt) {
        throw;
    }

                                       
    minimumFundingGoal = _minimumFundingGoal;
  }

     
                                                       
     
  function() payable {
    throw;
  }

     
                        
    
                                                 
                                                  
    
    
     
  function invest(address receiver) inState(State.Funding) stopInEmergency payable public {

    uint weiAmount = msg.value;
    uint tokenAmount = pricingStrategy.calculatePrice(weiAmount, weiRaised, tokensSold, msg.sender);

    if(tokenAmount == 0) {
                         
      throw;
    }

    if(investedAmountOf[receiver] == 0) {
                        
       investorCount++;
    }

                      
    investedAmountOf[receiver] = investedAmountOf[receiver].plus(weiAmount);
    tokenAmountOf[receiver] = tokenAmountOf[receiver].plus(tokenAmount);

                    
    weiRaised = weiRaised.plus(weiAmount);
    tokensSold = tokensSold.plus(tokenAmount);

                                         
    if(isBreakingCap(tokenAmount, weiAmount, weiRaised, tokensSold)) {
      throw;
    }

    assignTokens(receiver, tokenAmount);

                       
    if(!multisigWallet.send(weiAmount)) throw;

                                 
    Invested(receiver, weiAmount, tokenAmount);
  }

     
                                                                
    
                                                                     
     
  function buy() public payable {
    invest(msg.sender);
  }

     
                                     
    
                                                          
    
                                                                                       
     
  function finalize() public inState(State.Success) stopInEmergency {

                        
    if(finalized) {
      throw;
    }

                                                                                  
    if(address(finalizeAgent) != 0) {
      finalizeAgent.finalizeCrowdsale();
    }

    finalized = true;
  }

  function setFinalizeAgent(FinalizeAgent addr) onlyOwner inState(State.Preparing) {
    finalizeAgent = addr;

                                    
    if(!finalizeAgent.isFinalizeAgent()) {
      throw;
    }
  }

     
                                                               
    
                                                                                                              
     
  function loadRefund() public payable inState(State.Failure) {
    if(msg.value == 0) throw;
    loadedRefund = loadedRefund.plus(msg.value);
  }

     
                                
     
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0) throw;
    investedAmountOf[msg.sender] = 0;
    weiRefunded = weiRefunded.plus(weiValue);
    Refund(msg.sender, weiValue);
    if (!msg.sender.send(weiValue)) throw;
  }

     
                                                                         
     
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiRaised >= minimumFundingGoal;
  }

     
                                        
    
                                                                                                                         
     
  function getState() public constant returns (State) {
    if(finalized) return State.Finalized;
    else if (address(finalizeAgent) == 0) return State.Preparing;
    else if (!finalizeAgent.isSane()) return State.Preparing;
    else if (block.timestamp < startsAt) return State.PreFunding;
    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;
    else if (isMinimumGoalReached()) return State.Success;
    else if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised) return State.Refunding;
    else return State.Failure;
  }

                                                                  
  function setOwnerTestValue(uint val) onlyOwner {
    ownerTestValue = val;
  }

    
              
    

                                                                                 
  modifier inState(State state) {
    if(getState() != state) throw;
    _;
  }


    
                       
    

     
                                                        
    
    
                                                                
                                                                                          
                          
    
                                                                                               
                                                                                                      
                                                                                        
                                                                                            
    
                                                                     
     
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken);

     
                                                                                 
     
  function isCrowdsaleFull() public constant returns (bool);

     
                                                                                            
     
  function assignTokens(address receiver, uint tokenAmount) private;
}

contract MintedTokenCappedCrowdsale is Crowdsale {

                                                         
  uint public maximumSellableTokens;

  function MintedTokenCappedCrowdsale(address _token, address _pricingStrategy, address _multisigWallet, uint _start, uint _end, uint _minimumFundingGoal, uint _maximumSellableTokens) Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, _minimumFundingGoal) {
    maximumSellableTokens = _maximumSellableTokens;
  }

     
                                                                                          
     
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
    return tokensSoldTotal > maximumSellableTokens;
  }

  function isCrowdsaleFull() public constant returns (bool) {
    return tokensSold >= maximumSellableTokens;
  }

     
                                                               
     
  function assignTokens(address receiver, uint tokenAmount) private {
    MintableToken mintableToken = MintableToken(token);
    mintableToken.mint(receiver, tokenAmount);
  }
}