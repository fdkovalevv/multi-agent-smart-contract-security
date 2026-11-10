contract TwoXJackpot {
  using SafeMath for uint256;

                                    
  address public contractOwner;

               
  BuyIn[] public buyIns;

                                  
  uint256 public index;

                                       
  uint256 public contractTotalInvested;

                 
  uint256 public devFeeBalance;

                     
  uint256 public jackpotBalance;

                                                 
  uint256 public seedAmount;

                                                        
  address public jackpotLastQualified;

                                  
  uint256 public lastAction;

                            
  uint256 public gameStartTime;

                                       
  mapping (address => uint256) public totalInvested;

                                    
  mapping (address => uint256) public totalValue;

                                       
  mapping (address => uint256) public totalPaidOut;

  struct BuyIn {
    uint256 value;
    address owner;
  }

  modifier onlyContractOwner() {
    require(msg.sender == contractOwner);
    _;
  }

  modifier isStarted() {
      require(now >= gameStartTime);
      _;
  }

  function TwoXJackpot() public {
    contractOwner = msg.sender;
    gameStartTime = now + 24 hours;
  }

                       
                       
                       

                                                                             
  function killme() public payable onlyContractOwner {
    require(now > lastAction + 30 days);
    seedAmount = 0;
    jackpotBalance = 0;
    contractOwner.transfer(jackpotBalance);
  }

                                                                                                        
  function seed() public payable onlyContractOwner {
    seedAmount += msg.value;                                         
    jackpotBalance += msg.value;                                                   
  }

                           
  function changeStartTime(uint256 _time) public payable onlyContractOwner {
    require(now < _time);                                                      
    require(now < gameStartTime);                                                           
    gameStartTime = _time;
  }

                      
                      
                      

  function purchase() public payable isStarted {

    uint256 purchaseMin = SafeMath.mul(msg.value, 20);                           
    uint256 purchaseMax = SafeMath.mul(msg.value, 2);                            

    require(purchaseMin >= jackpotBalance);
    require(purchaseMax <= jackpotBalance);

                    
    uint256 valueAfterTax = SafeMath.div(SafeMath.mul(msg.value, 95), 100);

                                                                         
    uint256 potFee = SafeMath.sub(msg.value, valueAfterTax);

                            
    jackpotBalance += potFee;
    jackpotLastQualified = msg.sender;
    lastAction = now;

                    
    uint256 valueMultiplied = SafeMath.mul(msg.value, 2);

    contractTotalInvested += msg.value;
    totalInvested[msg.sender] += msg.value;

    while (index < buyIns.length && valueAfterTax > 0) {
      BuyIn storage buyIn = buyIns[index];

      if (valueAfterTax < buyIn.value) {
        buyIn.owner.transfer(valueAfterTax);
        totalPaidOut[buyIn.owner] += valueAfterTax;
        totalValue[buyIn.owner] -= valueAfterTax;
        buyIn.value -= valueAfterTax;
        valueAfterTax = 0;
      } else {
        buyIn.owner.transfer(buyIn.value);
        totalPaidOut[buyIn.owner] += buyIn.value;
        totalValue[buyIn.owner] -= buyIn.value;
        valueAfterTax -= buyIn.value;
        buyIn.value = 0;
        index++;
      }
    }

                                                          
                                 
    if (valueAfterTax > 0) {
      msg.sender.transfer(valueAfterTax);
      valueMultiplied -= valueAfterTax;
      totalPaidOut[msg.sender] += valueAfterTax;
    }

    totalValue[msg.sender] += valueMultiplied;

    buyIns.push(BuyIn({
      value: valueMultiplied,
      owner: msg.sender
    }));
  }


                                                                                                       
  function claim() public payable isStarted {
    require(now > lastAction + 6 hours);
	require(jackpotLastQualified == msg.sender);

    uint256 seedPay = seedAmount;
    uint256 jpotPay = jackpotBalance - seedAmount;

    seedAmount = 0;
    contractOwner.transfer(seedPay);                                     

    jackpotBalance = 0;
	msg.sender.transfer(jpotPay);                                     
  }

                                                                                       
  function () public payable {
    if(msg.value > 0) {
      purchase();
    } else {
      claim();
    }
  }
}