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
    require(newOwner != address(0));      
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

     
                                                              
     
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

     
                                                                 
     
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
  
}

contract PreSale is Pausable {
    
  event Invest(address, uint);

  using SafeMath for uint;
    
  address public wallet;

  uint public start;
  
  uint public total;
  
  uint16 public period;

  mapping (address => uint) balances;
  
  mapping (address => bool) invested;
  
  address[] public investors;
  
  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }
  
  function totalInvestors() constant returns (uint) {
    return investors.length;
  }
  
  function balanceOf(address investor) constant returns (uint) {
    return balances[investor];
  }
  
  function setStart(uint newStart) onlyOwner {
    start = newStart;
  }
  
  function setPeriod(uint16 newPeriod) onlyOwner {
    period = newPeriod;
  }
  
  function setWallet(address newWallet) onlyOwner {
    require(newWallet != address(0));
    wallet = newWallet;
  }

  function invest() saleIsOn whenNotPaused payable {
    wallet.transfer(msg.value);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    bool isInvested = invested[msg.sender];
    if(!isInvested) {
        investors.push(msg.sender);    
        invested[msg.sender] = true;
    }
    total = total.add(msg.value);
    Invest(msg.sender, msg.value);
  }

  function() external payable {
    invest();
  }

}