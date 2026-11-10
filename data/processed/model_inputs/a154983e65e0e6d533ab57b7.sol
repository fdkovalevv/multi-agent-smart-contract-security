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

contract Authorizable {
    mapping(address => bool) authorizers;

    modifier onlyAuthorized {
      require(isAuthorized(msg.sender));
      _;
    }

    function Authorizable() public {
      authorizers[msg.sender] = true;
    }


    function isAuthorized(address _addr) public constant returns(bool) {
      require(_addr != address(0));

      bool result = bool(authorizers[_addr]);
      return result;
    }

    function addAuthorized(address _addr) external onlyAuthorized {
      require(_addr != address(0));

      authorizers[_addr] = true;
    }

    function delAuthorized(address _addr) external onlyAuthorized {
      require(_addr != address(0));
      require(_addr != msg.sender);

                                   
      delete authorizers[_addr];
    }
}

contract MallcoinCrowdSale is Ownable, Authorizable {
      using SafeMath for uint256;

      MallcoinToken public token;
      address public wallet; 

      uint256 public PRE_ICO_START_TIME = 1519297200;                                            
      uint256 public PRE_ICO_END_TIME = 1520550000;                                        
      uint256 public PRE_ICO_BONUS_TIME_1 =  1519556400;                                          
      uint256 public PRE_ICO_BONUS_TIME_2 =  1519988400;                                      
      uint256 public PRE_ICO_BONUS_TIME_3 =  1520334000;                                       
      uint256 public PRE_ICO_RATE = 3000 * 1 ether;                      
      uint256 public PRE_ICO_BONUS_RATE = 75 * 1 ether;                 
      uint256 public preIcoTokenSales;

      uint256 public ICO_START_TIME = 1521716400;                                         
      uint256 public ICO_END_TIME = 1523574000;                                         
      uint256 public ICO_BONUS_TIME_1 = 1521975600;                                       
      uint256 public ICO_BONUS_TIME_2 = 1522839600;                                         
      uint256 public ICO_BONUS_TIME_3 = 1523358000;                                        
      uint256 public ICO_RATE = 2000 * 1 ether;                      
      uint256 public ICO_BONUS_RATE = 50 * 1 ether;                 
      uint256 public icoTokenSales;

      uint256 public SECRET_BONUS_FACTOR = 0;

      bool public crowdSaleStop = false;

      uint256 public MAX_TOKEN_SUPPLY = 250000000 * 1 ether;
      uint256 public MAX_CROWD_SALE_TOKENS = 185000000 * 1 ether;
      uint256 public weiRaised;
      uint256 public tokenSales;
      uint256 public bountyTokenFund;
      uint256 public reserveTokenFund;
      uint256 public teamTokenFund;


      event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
      event ChangeCrowdSaleDate(uint8 period, uint256 unixtime);

      modifier onlyOwnerOrAuthorized {
        require(msg.sender == owner || isAuthorized(msg.sender));
        _;
      }

      function MallcoinCrowdSale() public {
        wallet = owner;
        preIcoTokenSales = 0;
        icoTokenSales = 0;
        weiRaised = 0;
        tokenSales = 0;

        bountyTokenFund = 0;
        reserveTokenFund = 0;
        teamTokenFund = 0;
      
      }

   function () external payable {
     buyTokens(msg.sender);
   }

    function buyTokens(address beneficiary) public payable {
      require(beneficiary != address(0));
      require(validPurchase());

      uint256 weiAmount = msg.value;
      uint256 _buyTokens = 0;
      uint256 rate = 0;
      if (now >= PRE_ICO_START_TIME && now <= PRE_ICO_END_TIME) {
        rate = PRE_ICO_RATE.add(getPreIcoBonusRate());
        _buyTokens = rate.mul(weiAmount).div(1 ether);
        preIcoTokenSales = preIcoTokenSales.add(_buyTokens);
      } else if (now >= ICO_START_TIME && now <= ICO_END_TIME) {
        rate = ICO_RATE.add(getIcoBonusRate());
        _buyTokens = rate.mul(weiAmount).div(1 ether);
        icoTokenSales = icoTokenSales.add(_buyTokens);
      }

      require(MAX_CROWD_SALE_TOKENS >= tokenSales.add(_buyTokens));

      tokenSales = tokenSales.add(_buyTokens);
      weiRaised = weiRaised.add(weiAmount);
      wallet.transfer(msg.value);
      token.createToken(beneficiary, _buyTokens);
      TokenPurchase(msg.sender, beneficiary, weiAmount, _buyTokens);
    }

    function buyTokensByAtes(address addr_, uint256 amount_, string data_) onlyOwnerOrAuthorized  public returns (bool) {
      require(addr_ != address(0));
      require(amount_ > 0);
      require(bytes(data_).length > 0);
      require(validPurchase());

      uint256 _buyTokens = 0;
      uint256 rate = 0;
      if (now >= PRE_ICO_START_TIME && now <= PRE_ICO_END_TIME) {
        rate = PRE_ICO_RATE.add(getPreIcoBonusRate());
        _buyTokens = rate.mul(amount_).div(1

ether);
        preIcoTokenSales = preIcoTokenSales.add(_buyTokens);
      } else if (now >= ICO_START_TIME && now <= ICO_END_TIME) {
        rate = ICO_RATE.add(getIcoBonusRate());
        _buyTokens = rate.mul(amount_).div(1 ether);
        icoTokenSales = icoTokenSales.add(_buyTokens);
      }

      require(MAX_CROWD_SALE_TOKENS >= tokenSales.add(_buyTokens));

      tokenSales = tokenSales.add(_buyTokens);
      weiRaised = weiRaised.add(amount_);
      token.createTokenByAtes(addr_, _buyTokens, data_);
      TokenPurchase(msg.sender, addr_, amount_, _buyTokens);

      return true;
    }

    function getPreIcoBonusRate() private view returns (uint256 bonus) {
      bonus = 0;
      uint256 factorBonus = getFactorBonus();

      if (factorBonus > 0) {
        if (now >= PRE_ICO_START_TIME && now < PRE_ICO_BONUS_TIME_1) {                                          
          factorBonus = factorBonus.add(7);
          bonus = PRE_ICO_BONUS_RATE.mul(factorBonus);                   
        } else if (now >= PRE_ICO_BONUS_TIME_1 && now < PRE_ICO_BONUS_TIME_2) {                                      
          factorBonus = factorBonus.add(5);
          bonus = PRE_ICO_BONUS_RATE.mul(factorBonus);                   
        } else if (now >= PRE_ICO_BONUS_TIME_2 && now < PRE_ICO_BONUS_TIME_3) {                                       
          factorBonus = factorBonus.add(1);
          bonus = PRE_ICO_BONUS_RATE.mul(factorBonus);                   
        } 
      }

      return bonus;
    }

    function getIcoBonusRate() private view returns (uint256 bonus) {
      bonus = 0;
      uint256 factorBonus = getFactorBonus();

      if (factorBonus > 0) {
        if (now >= ICO_START_TIME && now < ICO_BONUS_TIME_1) {                                       
          factorBonus = factorBonus.add(7);
          bonus = ICO_BONUS_RATE.mul(factorBonus);                   
        } else if (now >= ICO_BONUS_TIME_1 && now < ICO_BONUS_TIME_2) {                                         
          factorBonus = factorBonus.add(5);
          bonus = ICO_BONUS_RATE.mul(factorBonus);                   
        } else if (now >= ICO_BONUS_TIME_2 && now < ICO_BONUS_TIME_3) {                                        
          factorBonus = factorBonus.add(1);
          bonus = ICO_BONUS_RATE.mul(factorBonus);                   
        } else if (now >= ICO_BONUS_TIME_3 && now < ICO_END_TIME) {                      
          factorBonus = factorBonus.add(SECRET_BONUS_FACTOR);
          bonus = ICO_BONUS_RATE.mul(factorBonus);                   
        } 
      }

      return bonus;
    }

    function getFactorBonus() private view returns (uint256 factor) {
      factor = 0;
      if (msg.value >= 5 ether && msg.value < 10 ether) {
        factor = 1;
      } else if (msg.value >= 10 ether && msg.value < 100 ether) {
        factor = 2;
      } else if (msg.value >= 100 ether) {
        factor = 3;
      }
      return factor;
    }

   function validPurchase() internal view returns (bool) {
      bool withinPeriod = false;
     if (now >= PRE_ICO_START_TIME && now <= PRE_ICO_END_TIME && !crowdSaleStop) {
        withinPeriod = true;
      } else if (now >= ICO_START_TIME && now <= ICO_END_TIME && !crowdSaleStop) {
        withinPeriod = true;
      }
     bool nonZeroPurchase = msg.value > 0;
      
     return withinPeriod && nonZeroPurchase;
   }

    function stopCrowdSale() onlyOwner public {
      crowdSaleStop = true;
    }

    function startCrowdSale() onlyOwner public {
      crowdSaleStop = false;
    }

    function changeCrowdSaleDates(uint8 _period, uint256 _unixTime) onlyOwner public {
      require(_period > 0 && _unixTime > 0);

      if (_period == 1) {
        PRE_ICO_START_TIME = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 2) {
        PRE_ICO_END_TIME = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 3) {
        PRE_ICO_BONUS_TIME_1 = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 4) {

PRE_ICO_BONUS_TIME_2 = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 5) {
        PRE_ICO_BONUS_TIME_3 = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 6) {
        ICO_START_TIME = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 7) {
        ICO_END_TIME = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 8) {
        ICO_BONUS_TIME_1 = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 9) {
        ICO_BONUS_TIME_2 = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } else if (_period == 10) {
        ICO_BONUS_TIME_3 = _unixTime;
        ChangeCrowdSaleDate(_period, _unixTime);
      } 
    }

    function setSecretBonusFactor(uint256 _factor) onlyOwner public {
      require(_factor >= 0);

      SECRET_BONUS_FACTOR = _factor;
    }
    
    function changeMallcoinTokenAddress(address _token) onlyOwner public {
      require(_token != address(0));

      token = MallcoinToken(_token);
    }

    function finishCrowdSale() onlyOwner public returns (bool) {
      crowdSaleStop = true;
      teamTokenFund = tokenSales.div(100).mul(10);                 
      bountyTokenFund = tokenSales.div(100).mul(7);                   
      reserveTokenFund = tokenSales.div(100).mul(9);                    

      uint256 tokensFund = teamTokenFund.add(bountyTokenFund).add(reserveTokenFund);
      wallet.transfer(this.balance);
      token.createToken(wallet, tokensFund);

      return true;
    }
}