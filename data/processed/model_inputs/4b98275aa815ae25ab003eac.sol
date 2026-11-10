contract Ownable {
  address public owner;                                                                          
  address public masterOwner = 0xe4925C73851490401b858B657F26E62e9aD20F66;                                                                             

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public {
    require(newOwner != address(0));
    require(masterOwner == msg.sender);                                                      
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

contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

                                                                      
    event Withdraw(address indexed from, address indexed to, uint256 value);
     
                                                  
                                                              
     
  function reclaimToken(address token) external onlyOwner {
    if (token == 0x0) {
      owner.transfer(this.balance);
      return;
    }
    ERC20Basic ecr20BasicToken = ERC20Basic(token);
    uint256 balance = ecr20BasicToken.balanceOf(this);
    ecr20BasicToken.safeTransfer(owner, balance);
    Withdraw(msg.sender, owner, balance);
  }

}

contract HasNoTokens is CanReclaimToken {

    
                                           
                                                                    
                                                           
                                                       
    
  function tokenFallback(address from_, uint256 value_, bytes data_) pure external {
    from_;
    value_;
    data_;
    revert();
  }

}

contract VZTPresale is Ownable, Pausable, HasNoTokens {


    using SafeMath for uint256;

    string public constant name = "VectorZilla Public Presale";                                  
    string public constant version = "1.0";                                 

    VZToken token;

                                                             
    address public constant VZT_WALLET = 0xa50EB7D45aA025525254aB2452679cE888B16b86;
                                                                                            
    uint256 public constant MIN_FUNDING_GOAL = 200 * 10 ** 18;
    uint256 public constant PRESALE_TOKEN_SOFT_CAP = 1875000 * 10 ** 18;                                        
    uint256 public constant PRESALE_RATE = 1250;                                                                  
    uint256 public constant SOFTCAP_RATE = 1150;                                                                                                
    uint256 public constant PRESALE_TOKEN_HARD_CAP = 5900000 * 10 ** 18;                            
    uint256 public constant MAX_GAS_PRICE = 50000000000;

    uint256 public minimumPurchaseLimit = 0.1 * 10 ** 18;                                                                               
    uint256 public startDate = 1516001400;                                                           
    uint256 public endDate = 1517815800;                                                            
    uint256 public totalCollected = 0;                                                                      
    uint256 public tokensSold = 0;                                                                      
    uint256 public totalDistributed = 0;                                                                                      
    uint256 public numWhitelisted = 0;                                                           

    struct PurchaseLog {
        uint256 ethValue;
        uint256 vztValue;
        bool kycApproved;
        bool tokensDistributed;
        bool paidFiat;
        uint256 lastPurchaseTime;
        uint256 lastDistributionTime;
    }

                                
    mapping (address => PurchaseLog) public purchaseLog;
                     
    mapping (address => bool) public refundLog;
                                                                       
    address[] public buyers;
    uint256 public buyerCount = 0;                                                                                     

    bool public isFinalized = false;                                                                                       
    bool public publicSoftCapReached = false;                                                                                

                                          
    mapping(address => bool) public whitelist;

                                       
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
                                             
    event Finalized();
                                        
    event SoftCapReached();
                                                                         
    event FundsTransferred();
                                                        
    event Refunded(address indexed beneficiary, uint256 weiAmount);
                                                                  
    event TokenDistributed(address indexed purchaser, uint256 tokenAmt);


      
                                             
      
    function VZTPresale(address _token, address _owner) public {
        require(_token != address(0));
        require(_owner != address(0));
        token = VZToken(_token);
                        
        owner = _owner;
    }

      
                                      
      

    function() payable public whenNotPaused {
        doPayment(msg.sender);
    }

      
                                                                                          
      
    function payableInFiatEth(address buyer, uint256 value) external onlyOwner {
        purchaseLog[buyer].paidFiat = true;
                            
        purchasePresale(buyer, value);
    }

    function setTokenContract(address _token) external onlyOwner {
        require(token != address(0));
        token = VZToken(_token);

    }

       
                              
                                                          
      
    function addToWhitelist(address _addr) public onlyOwner returns (bool) {
        require(_addr != address(0));
        if (!whitelist[_addr]) {
            whitelist[_addr] = true;
            numWhitelisted++;
        }
        purchaseLog[_addr].kycApproved = true;
        return true;
    }

        
                                
                                                            
        
    function addManyToWhitelist(address[] _addresses) 
        external 
        onlyOwner 
        returns (bool) 
        {
        require(_addresses.length <= 50);
        uint idx = 0;
        uint len = _addresses.length;
        for (; idx < len; idx++) {
            address _addr = _addresses[idx];
            addToWhitelist(_addr);
        }
        return true;
    }
       
                                    
                                                               
       
     function removeFomWhitelist(address _addr) public onlyOwner returns (bool) {
         require(_addr != address(0));
         require(whitelist[_addr]);
        delete whitelist[_addr];
        purchaseLog[_addr].kycApproved = false;
        numWhitelisted--;
        return true;
     }

      
                                      
                             
      
    function sendTokens(address _user) public onlyOwner returns (bool) {
        require(_user != address(0));
        require(_user != address(this));
        require(purchaseLog[_user].kycApproved);
        require(purchaseLog[_user].vztValue > 0);
        require(!purchaseLog[_user].tokensDistributed);
        require(!refundLog[_user]);
        purchaseLog[_user].tokensDistributed = true;
        purchaseLog[_user].lastDistributionTime = now;
        totalDistributed++;
        token.sendToken(_user, purchaseLog[_user].vztValue);
        TokenDistributed(_user, purchaseLog[_user].vztValue);
        return true;
    }

      
                                                               
      
    function refundEthIfKYCNotVerified(address _user) public onlyOwner returns (bool) {
        if (!purchaseLog[_user].kycApproved) {
            return doRefund(_user);
        }
        return false;
    }

      

      
                                           
      
    function isWhitelisted(address buyer) public view returns (bool) {
        return whitelist[buyer];
    }

      
                                               
      
    function isPresale() public view returns (bool) {
        return !isFinalized && now >= startDate && now <= endDate;
    }

      
                                        
      
    function hasSoldOut() public view returns (bool) {
        return PRESALE_TOKEN_HARD_CAP - tokensSold < getMinimumPurchaseVZTLimit();
    }

      
                                                                                  
                                    
      
    function hasEnded() public view returns (bool) {
        return now > endDate || hasSoldOut();
    }

      
                                                              
      
    function isMinimumGoalReached() public view returns (bool) {
        return totalCollected >= MIN_FUNDING_GOAL;
    }

      
                                                                        
      
    function getSoftCapReached() public view returns (bool) {
        return publicSoftCapReached;
    }

    function setMinimumPurchaseEtherLimit(uint256 newMinimumPurchaseLimit) external onlyOwner {
        require(newMinimumPurchaseLimit > 0);
        minimumPurchaseLimit = newMinimumPurchaseLimit;
    }
      
                                                                            
      

    function getMinimumPurchaseVZTLimit() public view returns (uint256) {
        if (getTier() == 1) {
            return minimumPurchaseLimit.mul(PRESALE_RATE);                
        } else if (getTier() == 2) {
            return minimumPurchaseLimit.mul(SOFTCAP_RATE);                
        }
        return minimumPurchaseLimit.mul(1000);             
    }

      
                                                                               
      
    function getTier() public view returns (uint256) {
                                           
        uint256 tier = 1;
        if (now >= startDate && now < endDate && getSoftCapReached()) {
                              
            tier = 2;
        }
        return tier;
    }

      
                                                                        
      
    function getPresaleStatus() public view returns (uint256[3]) {
                                  
                              
                            
        if (now < startDate)
            return ([0, startDate, endDate]);
        else if (now <= endDate && !hasEnded())
            return ([1, startDate, endDate]);
        else
            return ([2, startDate, endDate]);
    }

      
                                                                      
      
    function finalize() public onlyOwner {
                                  
        require(!isFinalized);
                                  
        require(hasEnded());

        if (isMinimumGoalReached()) {
                                                      
            VZT_WALLET.transfer(this.balance);
                                                 
            FundsTransferred();
        }
                            
        isFinalized = true;
                                             
        Finalized();
    }


       
                                                                                 
                                                                  
                                                                       
       
    function proxyPayment(address buyer) 
    payable 
    public
    whenNotPaused 
    returns(bool success) 
    {
        return doPayment(buyer);
    }

      
                                                    
      
    function setDates(uint256 newStartDate, uint256 newEndDate) public onlyOwner {
        require(newEndDate >= newStartDate);
        startDate = newStartDate;
        endDate = newEndDate;
    }


                                                                                
                                                                                 
                                                                
                                                                        
                                                        
    function doPayment(address buyer) internal returns(bool success) {
        require(tx.gasprice <= MAX_GAS_PRICE);
                   
                                                    
        require(buyer != address(0));
        require(!isContract(buyer));
                                                                   
                                                                                       
                                                       

        if (msg.sender != owner) {
                                      
            require(isPresale());
                                                          
            require(!hasSoldOut());
            require(msg.value >= minimumPurchaseLimit);
        }
        require(msg.value > 0);
        purchasePresale(buyer, msg.value);
        return true;
    }

                                                                       
                                              
                                             
    function isContract(address _addr) constant internal returns (bool) {
        if (_addr == 0) {
            return false;
        }
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

                                              
                                      
                                             
    function purchasePresale(address buyer, uint256 value) internal {
         require(value >= minimumPurchaseLimit);
         require(buyer != address(0));
        uint256 tokens = 0;
                               
        if (!publicSoftCapReached) {
                                  
            tokens = value * PRESALE_RATE;
                                       
            if (tokensSold + tokens > PRESALE_TOKEN_SOFT_CAP) {
                uint256 availablePresaleTokens = PRESALE_TOKEN_SOFT_CAP - tokensSold;
                uint256 softCapTokens = (value - (availablePresaleTokens / PRESALE_RATE)) * SOFTCAP_RATE;
                tokens = availablePresaleTokens + softCapTokens;
                                                        
                processSale(buyer, value, tokens, SOFTCAP_RATE);
                                                   
                publicSoftCapReached = true;
                                                     
                SoftCapReached();
            } else {
                                                
                processSale(buyer, value, tokens, PRESALE_RATE);
            }
        } else {
                                 
            tokens = value * SOFTCAP_RATE;
                                                    
            processSale(buyer, value, tokens, SOFTCAP_RATE);
        }
    }

      
                                         
      
    function processSale(address buyer, uint256 value, uint256 vzt, uint256 vztRate) internal {
        require(buyer != address(0));
        require(vzt > 0);
        require(vztRate > 0);
        require(value > 0);

        uint256 vztOver = 0;
        uint256 excessEthInWei = 0;
        uint256 paidValue = value;
        uint256 purchasedVzt = vzt;

        if (tokensSold + purchasedVzt > PRESALE_TOKEN_HARD_CAP) {                         
                           
            vztOver = tokensSold + purchasedVzt - PRESALE_TOKEN_HARD_CAP;
                                    
            excessEthInWei = vztOver / vztRate;
                                      
            purchasedVzt = purchasedVzt - vztOver;
                                
            paidValue = paidValue - excessEthInWei;
        }

                                                                                
                                                                                    
                                                                                           
          
        if (purchaseLog[buyer].vztValue == 0) {
            buyers.push(buyer);
            buyerCount++;
        }

                                              
        if (!isWhitelisted(buyer)) {
            purchaseLog[buyer].kycApproved = false;
        }
                                          
        refundLog[buyer] = false;

                                          
        purchaseLog[buyer].vztValue = SafeMath.add(purchaseLog[buyer].vztValue, purchasedVzt);
        purchaseLog[buyer].ethValue = SafeMath.add(purchaseLog[buyer].ethValue, paidValue);
        purchaseLog[buyer].lastPurchaseTime = now;


                           
        totalCollected += paidValue;
                         
        tokensSold += purchasedVzt;

          
                                                         
          
        address beneficiary = buyer;
        if (beneficiary == msg.sender) {
            beneficiary = msg.sender;
        }
                                             
        TokenPurchase(buyer, beneficiary, paidValue, purchasedVzt);
                                                                                                      
        if (excessEthInWei > 0 && !purchaseLog[buyer].paidFiat) {
                                 
            buyer.transfer(excessEthInWei);
                                                 
            Refunded(buyer, excessEthInWei);
        }
    }

      
                                     
                                      
                             
      
    function distributeTokensFor(address buyer) external onlyOwner returns (bool) {
        require(isFinalized);
        require(hasEnded());
        if (isMinimumGoalReached()) {
            return sendTokens(buyer);
        }
        return false;
    }

      
                                                                                  
      
    function claimRefund() external returns (bool) {
        return doRefund(msg.sender);
    }

      
                                                   
     
    function sendRefund(address buyer) external onlyOwner returns (bool) {
        return doRefund(buyer);
    }

      
                                            
      
    function doRefund(address buyer) internal returns (bool) {
        require(tx.gasprice <= MAX_GAS_PRICE);
        require(buyer != address(0));
        require(!purchaseLog[buyer].paidFiat);
        if (msg.sender != owner) {
                                              
            require(isFinalized && !isMinimumGoalReached());
        }
        require(purchaseLog[buyer].ethValue > 0);
        require(purchaseLog[buyer].vztValue > 0);
        require(!refundLog[buyer]);
        require(!purchaseLog[buyer].tokensDistributed);

                        
        uint256 depositedValue = purchaseLog[buyer].ethValue;
                       
        uint256 vztValue = purchaseLog[buyer].vztValue;
                                                         
                                                 
        purchaseLog[buyer].ethValue = 0;
        purchaseLog[buyer].vztValue = 0;
        refundLog[buyer] = true;
                                   
                                                     
        delete purchaseLog[buyer];
                                   
        tokensSold = tokensSold.sub(vztValue);
        totalCollected = totalCollected.sub(depositedValue);

                                                                          
                                    
        buyer.transfer(depositedValue);
        Refunded(buyer, depositedValue);
        return true;
    }

    function getBuyersList() external view returns (address[]) {
        return buyers;
    }

       
                                                                    
                                                  
      
    function reclaimEther() external onlyOwner {
        assert(owner.send(this.balance));
    }

}