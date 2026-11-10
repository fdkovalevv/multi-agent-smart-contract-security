contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    require(assertion);  
  }
}

contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);  
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
    require(!halted);
    _;
  }

  modifier onlyInEmergency {
    require(halted);       
    _;
  }

                                                              
  function halt() external onlyOwner {
    halted = true;
  }

                                                                      
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }
}

contract Killable is Ownable {
  function kill() onlyOwner {
    selfdestruct(owner);
  }
}

contract ZiberCrowdsale is Haltable, Killable, SafeMath {

                                               
  uint public constant TOTAL_ICO_TOKENS = 100000000;

                                                                                                  
  uint public constant MIN_ICO_GOAL = 5000 ether;

                                        
  uint public constant MAX_ICO_GOAL = 50000 ether;
  
                                         
  uint public maxGoalReachedAt = 0;

                         
  uint public constant ICO_DURATION = 10 days;

                         
  uint public constant AFTER_MAX_GOAL_DURATION = 24 hours;

                              
  ZiberToken public token;

                                                    
  uint public startsAt;

                                            
  uint public weiRaised = 0;

                                                                                  
  uint public loadedRefund = 0;

                                                   
  uint public weiRefunded = 0;

                                       
  bool public finalized;

                                                              
  mapping (address => uint256) public investedAmountOf;

                                                                           
  mapping (address => uint256) public tokenAmountOf;

                                                            
  struct Investment {
                      
      address source;
                         
      uint weiValue;
  }

  Investment[] public investments;

                   
                                                                                      
                                                   
                               
                                           
                                                                  
                                                                        
                                                                
  enum State {Unknown, Preparing, Funding, Success, Failure, Finalized, Refunding}

                               
  event Invested(address investor, uint weiAmount);
                                            
  event Refund(address investor, uint weiAmount);

                                                                                 
  modifier inState(State state) {
    require(getState() == state);
    _;
  }

                      
                                          
                                        
  function Crowdsale(address _token, uint _start) {
    require(_token != 0);
    require(_start != 0);

    owner = msg.sender;
    token = ZiberToken(_token);
    startsAt = _start;
  }

                                                         
  function() payable {
    buy();
  }

                                                                            
                                                                   
  function investInternal(address receiver) stopInEmergency private {
    var state = getState();
    require(state == State.Funding);
    require(msg.value > 0);

                            
    var weiAmount = msg.value;
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver], weiAmount);
    investments.push(Investment(receiver, weiAmount));

                    
    weiRaised = safeAdd(weiRaised, weiAmount);
                              
    if(maxGoalReachedAt == 0 && weiRaised >= MAX_ICO_GOAL)
      maxGoalReachedAt = now;
                                 
    Invested(receiver, weiAmount);
  }

                                                           
                                                                  
  function invest(address receiver) public payable {
    investInternal(receiver);
  }

                                                                      
  function buy() public payable {
    invest(msg.sender);
  }

                                           
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    require(!finalized);

    finalized = true;
    finalizeCrowdsale();
  }

                                            
  function withdraw() public onlyOwner {
                                        
    owner.transfer(this.balance);
  }

                                           
  function finalizeCrowdsale() internal {
                                                 
    uint divisor;
    for (uint i = 0; i < investments.length; i++)
       divisor = safeAdd(divisor, investments[i].weiValue);

    var multiplier = 10 ** token.decimals();
                     
    uint unitPrice = safeDiv(safeMul(TOTAL_ICO_TOKENS, multiplier), divisor);

                                        
    for (i = 0; i < investments.length; i++) {
        var tokenAmount = safeMul(unitPrice, investments[i].weiValue);
        tokenAmountOf[investments[i].source] += tokenAmount;
        assignTokens(investments[i].source, tokenAmount);
    }
    assignTokens(owner, 2e7);
    token.releaseTokenTransfer();
  }

                                                                     
  function loadRefund() public payable inState(State.Failure) {
    require(msg.value > 0);
    loadedRefund = safeAdd(loadedRefund, msg.value);
  }

                                      
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0)
      return;
    investedAmountOf[msg.sender] = 0;
    weiRefunded = safeAdd(weiRefunded, weiValue);
    Refund(msg.sender, weiValue);
    msg.sender.transfer(weiValue);
  }

                                   
                                                                                         
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiRaised >= MIN_ICO_GOAL;
  }

                                             
                                                                           
  function isCrowdsaleFull() public constant returns (bool) {
    return weiRaised >= MAX_ICO_GOAL && now > maxGoalReachedAt + AFTER_MAX_GOAL_DURATION;
  }

                                              
                                 
  function getState() public constant returns (State) {
    if (finalized)
      return State.Finalized;
    if (address(token) == 0)
      return State.Preparing;
    if (now >= startsAt && now < startsAt + ICO_DURATION && !isCrowdsaleFull())
      return State.Funding;
    if (isCrowdsaleFull())
      return State.Success;
    if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised)
      return State.Refunding;
    return State.Failure;
  }

                                                                      
                                       
                                                                                                        
   function assignTokens(address receiver, uint tokenAmount) private {
     token.mint(receiver, tokenAmount);
   }
}