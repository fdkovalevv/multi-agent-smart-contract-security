contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract IForegroundEnabledContract {
   function receiveEtherFromForegroundAddress(address _originatingAddress, address _relayedFromAddress, uint256 _promotionID, address _referrer) public payable;
}

contract ForegroundCaller is IForegroundEnabledContract {
    IForeground public foreground;

    function ForegroundCaller(IForeground _foreground) public {
        foreground = _foreground;
    }

                                                                                              
                                                                       
    event EtherReceivedFromRelay(address indexed _originatingAddress, uint256 indexed _promotionID, address indexed _referrer);
    event ForegroundPaymentResult(bool _success, uint256 indexed _promotionID, address indexed _referrer, uint256 _value);
    event ContractFunded(address indexed _sender, uint256 _value);

                                                                                                                     
    function receiveEtherFromForegroundAddress(address _originatingAddress, address _relayedFromAddress, uint256 _promotionID, address _referrer) public payable {
                                                                          
                                                                                                       
        EtherReceivedFromRelay(_originatingAddress, _promotionID, _referrer);

        uint256 _amountSpent = receiveEtherFromRelayAddress(_originatingAddress, msg.value);

                                                                                                                        
        uint256 _paymentToForeground = foreground.calculateTotalDue(_promotionID, _amountSpent);
                                                              
        bool _success = foreground.call.gas(1000000).value(_paymentToForeground)(bytes4(keccak256("payConversionFromTransaction(uint256,address,uint256)")), _promotionID, _referrer, _amountSpent);
        ForegroundPaymentResult(_success, _promotionID, _referrer, msg.value);
    }

                                                                  
    function receiveEtherFromRelayAddress(address _originatingAddress, uint256 _amount) internal returns(uint256 _amountSpent);

                                                                                                  
    function fundContract() payable {
        ContractFunded(msg.sender, msg.value);
    }
}

contract ForegroundTokenSale is Ownable, ForegroundCaller {
    using SafeMath for uint256;

    uint256 public publicTokenCap;
    uint256 public baseTokenPrice;
    uint256 public currentTokenPrice;

    uint256 public priceStepDuration;

    uint256 public numberOfParticipants;
    uint256 public maxSaleBalance;
    uint256 public minSaleBalance;
    uint256 public saleBalance;
    uint256 public tokenBalance;

    uint256 public startBlock;
    uint256 public endBlock;

    address public saleWalletAddress;

    address public devTeamTokenAddress;
    address public partnershipsTokenAddress;
    address public incentiveTokenAddress;
    address public bountyTokenAddress;

    bool public saleSuspended = false;

    DealToken public dealToken;
    SaleState public state;

    mapping (address => PurchaseDetails) public purchases;

    struct PurchaseDetails {
        uint256 tokenBalance;
        uint256 weiBalance;
    }

    enum SaleState {Prepared, Deployed, Configured, Started, Ended, Finalized, Refunding}

    event TokenPurchased(address indexed buyer, uint256 tokenPrice, uint256 txAmount, uint256 actualPurchaseAmount, uint256 refundedAmount, uint256 tokensPurchased);
    event SaleStarted();
    event SaleEnded();
    event Claimed(address indexed owner, uint256 tokensClaimed);
    event Refunded(address indexed buyer, uint256 amountRefunded);

       
                                                                                                                                                          
       
    modifier evaluateSaleState {
        require(saleSuspended == false);

        if (state == SaleState.Configured && block.number >= startBlock) {
            state = SaleState.Started;
            SaleStarted();
        }

        if (state == SaleState.Started) {
            setCurrentPrice();
        }

        if (state == SaleState.Started && (block.number > endBlock || saleBalance == maxSaleBalance || maxSaleBalance.sub(saleBalance) < currentTokenPrice)) {
            endSale();
        }

        if (state == SaleState.Ended) {
            finalizeSale();
        }
        _;
    }

       
                                                                
                                                                                 
                                                                                              
                                                  
                                                                                                      
       
    function ForegroundTokenSale(
        uint256 _publicTokenCap,
        uint256 _tokenFloor,
        uint256 _tokenRate,
        IForeground _foreground
    )
        public
        ForegroundCaller(_foreground)
    {
        require(_publicTokenCap > 0);
        require(_tokenFloor < _publicTokenCap);
        require(_tokenRate > 0);

        publicTokenCap = _publicTokenCap;
        baseTokenPrice = _tokenRate;
        currentTokenPrice = _tokenRate;

        dealToken = new DealToken();
        maxSaleBalance = publicTokenCap.mul(currentTokenPrice);
        minSaleBalance = _tokenFloor.mul(currentTokenPrice);
        state = SaleState.Deployed;
    }

       
                                                                             
       
    function() public payable {
        purchaseToken(msg.sender, msg.value);
    }

       
                                                                            
                                                          
                                                      
                                                                                              
                                                                       
                                                                                                  
                                                                                                  
                                                                                              
                                                                                         
       
    function configureSale(
        uint256 _startBlock,
        uint256 _endBlock,
        address _wallet,
        uint256 _stepDuration,
        address _devAddress,
        address _partnershipAddress,
        address _incentiveAddress,
        address _bountyAddress
    )
        external
        onlyOwner
    {
        require(_startBlock >= block.number);
        require(_endBlock >= _startBlock);
        require(state == SaleState.Deployed);
        require(_wallet != 0x0);
        require(_stepDuration > 0);
        require(_devAddress != 0x0);
        require(_partnershipAddress != 0x0);
        require(_incentiveAddress != 0x0);
        require(_bountyAddress != 0x0);

        state = SaleState.Configured;
        startBlock = _startBlock;
        endBlock = _endBlock;
        saleWalletAddress = _wallet;
        priceStepDuration = _stepDuration;
        devTeamTokenAddress = _devAddress;
        partnershipsTokenAddress = _partnershipAddress;
        incentiveTokenAddress = _incentiveAddress;
        bountyTokenAddress = _bountyAddress;
    }

       
                                            
       
    function claimToken()
        external
        evaluateSaleState
    {
        require(state == SaleState.Finalized);
        require(purchases[msg.sender].tokenBalance > 0);

        uint256 _tokensPurchased = purchases[msg.sender].tokenBalance;
        purchases[msg.sender].tokenBalance = 0;
        purchases[msg.sender].weiBalance = 0;

                                 
        dealToken.transfer(msg.sender, _tokensPurchased);
        Claimed(msg.sender, _tokensPurchased);
    }

       
                                                                              
       
    function claimRefund()
        external
    {
        require(state == SaleState.Refunding);

        uint256 _amountToRefund = purchases[msg.sender].weiBalance;
        require(_amountToRefund > 0);
        purchases[msg.sender].weiBalance = 0;
        purchases[msg.sender].tokenBalance = 0;
        msg.sender.transfer(_amountToRefund);
        Refunded(msg.sender, _amountToRefund);
    }

       
                                                                         
                                                                                       
       
    function suspendSale(bool _suspend)
        external
        onlyOwner
    {
        saleSuspended = _suspend;
    }

       
                                                                              
                                                          
       
    function updateLatestSaleState()
        external
        evaluateSaleState
        returns (uint256)
    {
        return uint256(state);
    }

       
                                                                      
                                                                    
                                                           
       
    function purchaseToken(address _recipient, uint256 _amount)
        internal
        evaluateSaleState
        returns (uint256)
    {
        require(state == SaleState.Started);
        require(_amount >= currentTokenPrice);

        uint256 _saleRemainingBalance = maxSaleBalance.sub(saleBalance);
        bool _shouldEndSale = false;

                                                                                            
        uint256 _amountToRefund = _amount % currentTokenPrice;
        uint256 _purchaseAmount = _amount.sub(_amountToRefund);

                                                                                                  
        if (_saleRemainingBalance < _purchaseAmount) {
            uint256 _endOfSaleRefund = _saleRemainingBalance % currentTokenPrice;
            _amountToRefund = _amountToRefund.add(_purchaseAmount.sub(_saleRemainingBalance).add(_endOfSaleRefund));
            _purchaseAmount = _saleRemainingBalance.sub(_endOfSaleRefund);
            _shouldEndSale = true;
        }

                                                     
        if (purchases[_recipient].tokenBalance == 0) {
            numberOfParticipants = numberOfParticipants.add(1);
        }

        uint256 _tokensPurchased = _purchaseAmount.div(currentTokenPrice);
        purchases[_recipient].tokenBalance = purchases[_recipient].tokenBalance.add(_tokensPurchased);
        purchases[_recipient].weiBalance = purchases[_recipient].weiBalance.add(_purchaseAmount);
        saleBalance = saleBalance.add(_purchaseAmount);
        tokenBalance = tokenBalance.add(_tokensPurchased);

        if (_purchaseAmount == _saleRemainingBalance || _shouldEndSale) {
            endSale();
        }

                                                 
        if (_amountToRefund > 0) {
            _recipient.transfer(_amountToRefund);
        }

        TokenPurchased(_recipient, currentTokenPrice, msg.value, _purchaseAmount, _amountToRefund, _tokensPurchased);
        return _purchaseAmount;
    }

       
                                                                      
                                                                             
                                                           
                                                                                                       
       
    function receiveEtherFromRelayAddress(address _originatingAddress, uint256 _amount)
        internal
        returns (uint256)
    {
        return purchaseToken(_originatingAddress, _amount);
    }

       
                                                                                                    
       
    function setCurrentPrice() internal {
        uint256 _saleBlockNo = block.number - startBlock;
        uint256 _numIncreases = _saleBlockNo.div(priceStepDuration);

        if (_numIncreases == 0)
            currentTokenPrice = baseTokenPrice;
        else if (_numIncreases == 1)
            currentTokenPrice = 0.06 ether;
        else if (_numIncreases == 2)
            currentTokenPrice = 0.065 ether;
        else if (_numIncreases == 3)
            currentTokenPrice = 0.07 ether;
        else if (_numIncreases >= 4)
            currentTokenPrice = 0.08 ether;
    }

       
                                                                                                    
       
    function endSale() internal {
                                                                                                                     
        if (saleBalance < minSaleBalance) {
            state = SaleState.Refunding;
        } else {
            state = SaleState.Ended;
                                                           
            mintTokens();
        }
        SaleEnded();
    }

       
                                                                                       
       
    function mintTokens() internal {
        uint256 _totalTokens = (tokenBalance.mul(10 ** 18)).div(74).mul(100);

                                                                                           
        dealToken.mint(address(this), _totalTokens.div(10 ** 18));

                                          
        dealToken.transfer(devTeamTokenAddress, (_totalTokens.mul(10).div(100)).div(10 ** 18));
        dealToken.transfer(partnershipsTokenAddress, (_totalTokens.mul(10).div(100)).div(10 ** 18));
        dealToken.transfer(incentiveTokenAddress, (_totalTokens.mul(4).div(100)).div(10 ** 18));
        dealToken.transfer(bountyTokenAddress, (_totalTokens.mul(2).div(100)).div(10 ** 18));

                                                                 
        dealToken.finishMinting();
    }

       
                                                                                   
       
    function finalizeSale() internal {
        state = SaleState.Finalized;
                                                      
        saleWalletAddress.transfer(this.balance);
    }
}