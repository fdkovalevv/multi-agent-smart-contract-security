contract PullPayment {

  using SafeMath for uint;
  
  mapping(address => uint) public payments;

  event LogRefundETH(address to, uint value);


     
                                                               
     
  function asyncSend(address dest, uint amount) internal {
    payments[dest] = payments[dest].add(amount);
  }

                                                  
  function withdrawPayments() {
    address payee = msg.sender;
    uint payment = payments[payee];
    
    if (payment == 0) {
      throw;
    }

    if (this.balance < payment) {
      throw;
    }

    payments[payee] = 0;

    if (!payee.send(payment)) {
      throw;
    }
    LogRefundETH(payee,payment);
  }
}

contract Ownable {
    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract Pausable is Ownable {
  bool public stopped;

  modifier stopInEmergency {
    if (stopped) {
      throw;
    }
    _;
  }
  
  modifier onlyInEmergency {
    if (!stopped) {
      throw;
    }
    _;
  }

                                                             
  function emergencyStop() external onlyOwner {
    stopped = true;
  }

                                                                     
  function release() external onlyOwner onlyInEmergency {
    stopped = false;
  }

}

contract Crowdsale is Pausable, PullPayment {
    
    using SafeMath for uint;

    struct Backer {
        uint weiReceived;                         
        uint coinSent;
    }

      
               
      
                                       
    uint public constant MIN_CAP = 1000000000000; 
                                       
    uint public constant MAX_CAP = 40000000000000000;
                                  
    uint public constant MIN_INVEST_ETHER = 10 finney;
                          
    uint private constant CROWDSALE_PERIOD = 21 days;
                                 
    uint public constant COIN_PER_ETHER = 1000000000000;


      
               
      
                                
    Tix public coin;
                                                       
    address public multisigEther;
                                  
    uint public etherReceived;
                                                  
    uint public coinSentToEther;
                              
    uint public startTime;
                            
    uint public endTime;
                                     
    bool public crowdsaleClosed;

                                                         
    mapping(address => Backer) public backers;


      
               
      
    modifier minCapNotReached() {
        if ((now < endTime) || coinSentToEther >= MIN_CAP ) throw;
        _;
    }

    modifier respectTimeFrame() {
        if ((now < startTime) || (now > endTime )) throw;
        _;
    }

      
            
      
    event LogReceivedETH(address addr, uint value);
    event LogCoinsEmited(address indexed from, uint amount);

      
                  
      
    function Crowdsale(address _tixAddress, address _to) {
        coin = Tix(_tixAddress);
        multisigEther = _to;
    }

       
                                                             
       
    function() stopInEmergency respectTimeFrame payable {
        receiveETH(msg.sender);
    }

       
                                     
       
    function start() onlyOwner {
        if (startTime != 0) throw;                                 

        startTime = now ;            
        endTime =  now + CROWDSALE_PERIOD;    
    }

      
                                    
      
    function receiveETH(address beneficiary) internal {
        if (msg.value < MIN_INVEST_ETHER) throw;                                                     
        
        uint coinToSend = bonus(msg.value.mul(COIN_PER_ETHER).div(1 ether));                                     
        if (coinToSend.add(coinSentToEther) > MAX_CAP) throw;   

        Backer backer = backers[beneficiary];
        coin.transfer(beneficiary, coinToSend);                           

        backer.coinSent = backer.coinSent.add(coinToSend);
        backer.weiReceived = backer.weiReceived.add(msg.value);                                                                              

        etherReceived = etherReceived.add(msg.value);                                                          
        coinSentToEther = coinSentToEther.add(coinToSend);

                      
        LogCoinsEmited(msg.sender ,coinToSend);
        LogReceivedETH(beneficiary, etherReceived); 
    }
    

      
                                                              
       
    function bonus(uint amount) internal constant returns (uint) {
        if (now < startTime.add(5 days)) return amount.add(amount.div(5));               
        return amount;
    }

        
                                                                       
      
    function finalize() onlyOwner public {

        if (now < endTime) {                                                                       
            if (coinSentToEther == MAX_CAP) {
            } else {
                throw;
            }
        }

        if (coinSentToEther < MIN_CAP && now < endTime + 15 days) throw;                                                                                     

        if (!multisigEther.send(this.balance)) throw;                                                    
        
        uint remains = coin.balanceOf(this);
        if (remains > 0) {                        
            if (!coin.burn(remains)) throw ;
        }
        crowdsaleClosed = true;
    }

        
                    
      
    function drain() onlyOwner {
        if (!owner.send(this.balance)) throw;
    }

       
                                                                          
       
    function setMultisig(address addr) onlyOwner public {
        if (addr == address(0)) throw;
        multisigEther = addr;
    }

       
                                       
       
    function backTixOwner() onlyOwner public {
        coin.transferOwnership(owner);
    }

       
                                                                       
       
    function getRemainCoins() onlyOwner public {
        var remains = MAX_CAP - coinSentToEther;
        uint minCoinsToSell = bonus(MIN_INVEST_ETHER.mul(COIN_PER_ETHER) / (1 ether));

        if(remains > minCoinsToSell) throw;

        Backer backer = backers[owner];
        coin.transfer(owner, remains);                           

        backer.coinSent = backer.coinSent.add(remains);

        coinSentToEther = coinSentToEther.add(remains);

                      
        LogCoinsEmited(this ,remains);
        LogReceivedETH(owner, etherReceived); 
    }


       
                                 
                                                                                                                                 
                                                                                                 
                                                                                                      
       
    function refund(uint _value) minCapNotReached public {
        
        if (_value != backers[msg.sender].coinSent) throw;                                     

        coin.transferFrom(msg.sender, address(this), _value);                                                

        if (!coin.burn(_value)) throw ;                                   

        uint ETHToSend = backers[msg.sender].weiReceived;
        backers[msg.sender].weiReceived=0;

        if (ETHToSend > 0) {
            asyncSend(msg.sender, ETHToSend);                                     
        }
    }

}