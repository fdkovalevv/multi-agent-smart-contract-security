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

contract PresaleFundCollector is Ownable {

  using SafeMathLib for uint;

                                                                
  uint public MAX_INVESTORS = 32;

                                       
  uint public investorCount;

                                         
  address[] public investors;

                                    
  mapping(address => uint) public balances;

                                                        
  uint public freezeEndsAt;

                                   
  uint public weiMinimumLimit;

                                    
  bool public moving;

                                                      
  Crowdsale public crowdsale;

  event Invested(address investor, uint value);
  event Refunded(address investor, uint value);

     
                                                               
     
  function PresaleFundCollector(address _owner, uint _freezeEndsAt, uint _weiMinimumLimit) {

    owner = _owner;

                    
    if(_freezeEndsAt == 0) {
      throw;
    }

                    
    if(_weiMinimumLimit == 0) {
      throw;
    }

    weiMinimumLimit = _weiMinimumLimit;
    freezeEndsAt = _freezeEndsAt;
  }

     
                              
     
  function invest() public payable {

                                                                    
    if(moving) throw;

    address investor = msg.sender;

    bool existing = balances[investor] > 0;

    balances[investor] = balances[investor].plus(msg.value);

                                    
    if(balances[investor] < weiMinimumLimit) {
      throw;
    }

                             
    if(!existing) {

                                                            
      if(investorCount >= MAX_INVESTORS) throw;

      investors.push(investor);
      investorCount++;
    }

    Invested(investor, msg.value);
  }

     
                                                       
     
  function parcipateCrowdsaleInvestor(address investor) public {

                            
    if(address(crowdsale) == 0) throw;

    moving = true;

    if(balances[investor] > 0) {
      uint amount = balances[investor];
      delete balances[investor];
      crowdsale.invest.value(amount)(investor);
    }
  }

     
                                                  
    
     
  function parcipateCrowdsaleAll() public {

                                                 
                                                                                          
    for(uint i=0; i<investors.length; i++) {
       parcipateCrowdsaleInvestor(investors[i]);
    }
  }

     
                                      
     
  function refund() {

                                    
    if(now < freezeEndsAt) throw;

                                    
    moving = true;

    address investor = msg.sender;
    if(balances[investor] == 0) throw;
    uint amount = balances[investor];
    delete balances[investor];
    if(!investor.send(amount)) throw;
    Refunded(investor, amount);
  }

     
                                                                                        
     
  function setCrowdsale(Crowdsale _crowdsale) public onlyOwner {
     crowdsale = _crowdsale;
  }

                                                   
  function() payable {
    throw;
  }
}