contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


     
                                                                                         
             
     
  constructor() public {
    owner = msg.sender;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

     
                                                                         
                                                                              
                                                                       
                      
     
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

     
                                                                                     
                                                           
     
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

     
                                                          
                                                           
     
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract Withdrawable is Ownable {

                                                                                   
                                                                              
                                                                              
                                                                             
                                                                         
    function withdrawToken(address _token, uint256 _amount) external onlyOwner returns (bool) {
        return ERC20SafeTransfer.safeTransfer(_token, owner, _amount);
    }

                                                                                   
                                                                              
                                                                            
    function withdrawETH(uint256 _amount) external onlyOwner {
        owner.transfer(_amount);
    }
}

contract Pausable is Ownable {
  event Paused();
  event Unpaused();

  bool private _paused = false;

     
                                                             
     
  function paused() public view returns (bool) {
    return _paused;
  }

     
                                                                                    
     
  modifier whenNotPaused() {
    require(!_paused, "Contract is paused.");
    _;
  }

     
                                                                                
     
  modifier whenPaused() {
    require(_paused, "Contract not paused.");
    _;
  }

     
                                                              
     
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused();
  }

     
                                                                 
     
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused();
  }
}

contract TotlePrimary is Withdrawable, Pausable {

      
                       
      

    mapping(address => bool) public handlerWhitelistMap;
    address[] public handlerWhitelistArray;
    AffiliateRegistry affiliateRegistry;
    address public defaultFeeAccount;

    TokenTransferProxy public tokenTransferProxy;
    ErrorReporter public errorReporter;
                               

      
             
      

              
    struct Trade {
        bool isSell;
        address tokenAddress;
        uint256 tokenAmount;
        bool optionalTrade;
        uint256 minimumExchangeRate;
        uint256 minimumAcceptableTokenAmount;
        Order[] orders;
    }

    struct Order {
        address exchangeHandler;
        bytes genericPayload;
    }

    struct TradeFlag {
        bool ignoreTrade;
        bool[] ignoreOrder;
    }

    struct CurrentAmounts {
        uint256 amountSpentOnTrade;
        uint256 amountReceivedFromTrade;
        uint256 amountLeftToSpendOnTrade;
    }

      
              
      

    event LogRebalance(
        bytes32 id,
        uint256 totalEthTraded,
        uint256 totalFee,
        address feeAccount
    );

    event LogTrade(
        bool isSell,
        address token,
        uint256 ethAmount,
        uint256 tokenAmount
    );

      
                 
      

    modifier handlerWhitelisted(address handler) {
        if (!handlerWhitelistMap[handler]) {
            errorReporter.revertTx("Handler not in whitelist");
        }
        _;
    }

    modifier handlerNotWhitelisted(address handler) {
        if (handlerWhitelistMap[handler]) {
            errorReporter.revertTx("Handler already whitelisted");
        }
        _;
    }

                           
                                                                    
                                                                        
    constructor (address _tokenTransferProxy, address _affiliateRegistry, address _errorReporter, address _defaultFeeAccount                     ) public {
                                               
        tokenTransferProxy = TokenTransferProxy(_tokenTransferProxy);
        affiliateRegistry = AffiliateRegistry(_affiliateRegistry);
        errorReporter = ErrorReporter(_errorReporter);
        defaultFeeAccount = _defaultFeeAccount;
                                       
    }

      
                        
      

                                              
                                                                              
                                                           
    function updateDefaultFeeAccount(address newDefaultFeeAccount) public onlyOwner {
        defaultFeeAccount = newDefaultFeeAccount;
    }

                                                               
                                                                              
                                                                                    
    function addHandlerToWhitelist(address handler)
        public
        onlyOwner
        handlerNotWhitelisted(handler)
    {
        handlerWhitelistMap[handler] = true;
        handlerWhitelistArray.push(handler);
    }

                                                                    
                                                                              
                                                                                      
    function removeHandlerFromWhitelist(address handler)
        public
        onlyOwner
        handlerWhitelisted(handler)
    {
        delete handlerWhitelistMap[handler];
        for (uint i = 0; i < handlerWhitelistArray.length; i++) {
            if (handlerWhitelistArray[i] == handler) {
                handlerWhitelistArray[i] = handlerWhitelistArray[handlerWhitelistArray.length - 1];
                handlerWhitelistArray.length -= 1;
                break;
            }
        }
    }

    struct FeeVariables{
        uint256 feePercentage;
        Affiliate affiliate;
        uint256 totalFee;
    }
                                                          
                                                      
    function performRebalance(
        Trade[] memory trades,
        address feeAccount,
        bytes32 id
    )
        public
        payable
        whenNotPaused
    {
        if(!affiliateRegistry.isValidAffiliate(feeAccount)){
            feeAccount = defaultFeeAccount;
        }
        FeeVariables memory feeVariables = FeeVariables(0, Affiliate(feeAccount), 0);
        feeVariables.feePercentage  = feeVariables.affiliate.getTotalFeePercentage();
                                                  

        TradeFlag[] memory tradeFlags = initialiseTradeFlags(trades);

        staticChecks(trades, tradeFlags);

                                                  

        transferTokens(trades, tradeFlags);

                                                

        uint256 etherBalance = msg.value;
                                                                            
        uint256 totalTraded = 0;
        for (uint256 i; i < trades.length; i++) {
            Trade memory thisTrade = trades[i];
            TradeFlag memory thisTradeFlag = tradeFlags[i];

            CurrentAmounts memory amounts = CurrentAmounts({
                amountSpentOnTrade: 0,
                amountReceivedFromTrade: 0,
                amountLeftToSpendOnTrade: thisTrade.isSell ? thisTrade.tokenAmount : calculateMaxEtherSpend(thisTrade, etherBalance, feeVariables.feePercentage)
            });
                                                                                                                         

            performTrade(
                thisTrade,
                thisTradeFlag,
                amounts
            );
            emit LogTrade(thisTrade.isSell, thisTrade.tokenAddress, thisTrade.isSell ? amounts.amountReceivedFromTrade:amounts.amountSpentOnTrade, thisTrade.isSell?amounts.amountSpentOnTrade:amounts.amountReceivedFromTrade);

            uint256 ethTraded;
            uint256 ethFee;
            if(thisTrade.isSell){
                ethTraded = amounts.amountReceivedFromTrade;
            } else {
                ethTraded = amounts.amountSpentOnTrade;
            }
            totalTraded += ethTraded;
            ethFee = calculateFee(ethTraded, feeVariables.feePercentage);
            feeVariables.totalFee = SafeMath.add(feeVariables.totalFee, ethFee);
                                                                                                                                                                                

            if (amounts.amountReceivedFromTrade == 0 && thisTrade.optionalTrade) {
                                                                                                   
                continue;
            }

                          
                                                                                                                   
                                           
                                               
                 

            if (!checkIfTradeAmountsAcceptable(thisTrade, amounts.amountSpentOnTrade, amounts.amountReceivedFromTrade)) {
                errorReporter.revertTx("Amounts spent/received in trade not acceptable");
            }

                                                                           

            if (thisTrade.isSell) {
                              
                                                                                                                          
                                 
                                                   
                     
                etherBalance = SafeMath.sub(SafeMath.add(etherBalance, ethTraded), ethFee);
            } else {
                              
                                                                                                                         
                                 
                                              
                     
                etherBalance = SafeMath.sub(SafeMath.sub(etherBalance, ethTraded), ethFee);
            }

                                                                                                                     

            transferTokensToUser(
                thisTrade.tokenAddress,
                thisTrade.isSell ? amounts.amountLeftToSpendOnTrade : amounts.amountReceivedFromTrade
            );

        }
        emit LogRebalance(id, totalTraded, feeVariables.totalFee, feeAccount);
        if(feeVariables.totalFee > 0){
            feeAccount.transfer(feeVariables.totalFee);
        }
        if(etherBalance > 0) {
                                                                                                                    
            msg.sender.transfer(etherBalance);
        }
    }

                                                                                
                                                                                                
                                                      
                                                                                    
    function staticChecks(
        Trade[] trades,
        TradeFlag[] tradeFlags
    )
        public
        view
        whenNotPaused
    {
        bool previousBuyOccured = false;

        for (uint256 i; i < trades.length; i++) {
            Trade memory thisTrade = trades[i];
            if (thisTrade.isSell) {
                if (previousBuyOccured) {
                    errorReporter.revertTx("A buy has occured before this sell");
                }

                if (!Utils.tokenAllowanceAndBalanceSet(msg.sender, thisTrade.tokenAddress, thisTrade.tokenAmount, address(tokenTransferProxy))) {
                    if (!thisTrade.optionalTrade) {
                        errorReporter.revertTx("Taker has not sent allowance/balance on a non-optional trade");
                    }
                                  
                                                                                                                                                           
                                              
                          
                          
                          
                                              
                         
                    tradeFlags[i].ignoreTrade = true;
                    continue;
                }
            } else {
                previousBuyOccured = true;
            }

                                                                                
            for (uint256 j; j < thisTrade.orders.length; j++) {
                Order memory thisOrder = thisTrade.orders[j];
                if ( !handlerWhitelistMap[thisOrder.exchangeHandler] ) {
                                  
                                                                                                 
                          
                          
                          
                          
                                                 
                         
                    tradeFlags[i].ignoreOrder[j] = true;
                    continue;
                }
            }
        }
    }

      
                          
      

                                                 
                                                             
                                                
    function initialiseTradeFlags(Trade[] trades)
        internal
        returns (TradeFlag[])
    {
                                                      
        TradeFlag[] memory tradeFlags = new TradeFlag[](trades.length);
        for (uint256 i = 0; i < trades.length; i++) {
            tradeFlags[i].ignoreOrder = new bool[](trades[i].orders.length);
        }
        return tradeFlags;
    }

                                                                           
                                                                
                                                           
    function transferTokensToUser(
        address tokenAddress,
        uint256 tokenAmount
    )
        internal
    {
                                                                                                                                      
        if (tokenAmount > 0) {
            if (!ERC20SafeTransfer.safeTransfer(tokenAddress, msg.sender, tokenAmount)) {
                errorReporter.revertTx("Unable to transfer tokens to user");
            }
        }
    }

                                        
                                                                    
                                                                     
                                                                          
                                     
    function performTrade(
        Trade memory trade,
        TradeFlag memory tradeFlag,
        CurrentAmounts amounts
    )
        internal
    {
                                             

        for (uint256 j; j < trade.orders.length; j++) {

            if(amounts.amountLeftToSpendOnTrade * 10000 < (amounts.amountSpentOnTrade + amounts.amountLeftToSpendOnTrade)){
                return;
            }

            if((trade.isSell ? amounts.amountSpentOnTrade : amounts.amountReceivedFromTrade) >= trade.tokenAmount ) {
                return;
            }

            if (tradeFlag.ignoreOrder[j] || amounts.amountLeftToSpendOnTrade == 0) {
                              
                                                                                                                    
                                                    
                     
                continue;
            }

            uint256 amountSpentOnOrder = 0;
            uint256 amountReceivedFromOrder = 0;

            Order memory thisOrder = trade.orders[j];

                                                                                                                             
            ExchangeHandler thisHandler = ExchangeHandler(thisOrder.exchangeHandler);

            uint256 amountToGiveForOrder = Utils.min(
                thisHandler.getAmountToGive(thisOrder.genericPayload),
                amounts.amountLeftToSpendOnTrade
            );

            if (amountToGiveForOrder == 0) {
                              
                                                                                                                                                                                 
                     
                continue;
            }

                          
                                                                                                               
                                     
                                                
                 

            if( !thisHandler.staticExchangeChecks(thisOrder.genericPayload) ) {
                                                                         
                continue;
            }

            if (trade.isSell) {
                                                     
                if (!ERC20SafeTransfer.safeTransfer(trade.tokenAddress,address(thisHandler), amountToGiveForOrder)) {
                    if( !trade.optionalTrade ) errorReporter.revertTx("Unable to transfer tokens to handler");
                    else {
                                                                                                           
                        return;
                    }
                }

                                                                   
                (amountSpentOnOrder, amountReceivedFromOrder) = thisHandler.performSellOrder(thisOrder.genericPayload, amountToGiveForOrder);
                                                                                                                                                              
            } else {
                                                                  
                (amountSpentOnOrder, amountReceivedFromOrder) = thisHandler.performBuyOrder.value(amountToGiveForOrder)(thisOrder.genericPayload, amountToGiveForOrder);
                                                                                                                                                             
            }


            if (amountReceivedFromOrder > 0) {
                amounts.amountLeftToSpendOnTrade = SafeMath.sub(amounts.amountLeftToSpendOnTrade, amountSpentOnOrder);
                amounts.amountSpentOnTrade = SafeMath.add(amounts.amountSpentOnTrade, amountSpentOnOrder);
                amounts.amountReceivedFromTrade = SafeMath.add(amounts.amountReceivedFromTrade, amountReceivedFromOrder);

                              
                                                                                                                               
                                                     
                                               
                                                   
                     
            }
        }

    }

                                                                               
                         
                                                            
                                                                        
                                                                                  
                                                        
    function checkIfTradeAmountsAcceptable(
        Trade trade,
        uint256 amountSpentOnTrade,
        uint256 amountReceivedFromTrade
    )
        internal
        view
        returns (bool passed)
    {
                                                                      
        uint256 tokenAmount = trade.isSell ? amountSpentOnTrade : amountReceivedFromTrade;
        passed = tokenAmount >= trade.minimumAcceptableTokenAmount;

                         
                        
                                                                                                                       
                            
                                                  
              
           

        if (passed) {
            uint256 tokenDecimals = Utils.getDecimals(ERC20(trade.tokenAddress));
            uint256 srcDecimals = trade.isSell ? tokenDecimals : Utils.eth_decimals();
            uint256 destDecimals = trade.isSell ? Utils.eth_decimals() : tokenDecimals;
            uint256 actualRate = Utils.calcRateFromQty(amountSpentOnTrade, amountReceivedFromTrade, srcDecimals, destDecimals);
            passed = actualRate >= trade.minimumExchangeRate;
        }

                         
                        
                                                                                                                   
                           
                                         
              
           
    }

                                                                                                                                           
                                                      
                                                                                    
    function transferTokens(Trade[] trades, TradeFlag[] tradeFlags) internal {
        for (uint256 i = 0; i < trades.length; i++) {
            if (trades[i].isSell && !tradeFlags[i].ignoreTrade) {

                              
                                                                                
                                          
                      
                      
                      
                                          
                     
                if (
                    !tokenTransferProxy.transferFrom(
                        trades[i].tokenAddress,
                        msg.sender,
                        address(this),
                        trades[i].tokenAmount
                    )
                ) {
                    errorReporter.revertTx("TTP unable to transfer tokens to primary");
                }
           }
        }
    }

                                                                                       
                                                                 
                                                                               
                                                                                 
    function calculateMaxEtherSpend(Trade trade, uint256 etherBalance, uint256 feePercentage) internal view returns (uint256) {
                                                                
        assert(!trade.isSell);

        uint256 tokenDecimals = Utils.getDecimals(ERC20(trade.tokenAddress));
        uint256 srcDecimals = trade.isSell ? tokenDecimals : Utils.eth_decimals();
        uint256 destDecimals = trade.isSell ? Utils.eth_decimals() : tokenDecimals;
        uint256 maxSpendAtMinRate = Utils.calcSrcQty(trade.tokenAmount, srcDecimals, destDecimals, trade.minimumExchangeRate);

        return Utils.min(removeFee(etherBalance, feePercentage), maxSpendAtMinRate);
    }

                                                                          
                                                             
                                                                          
    function calculateFee(uint256 amount, uint256 fee) internal view returns (uint256){
        return SafeMath.div(SafeMath.mul(amount, fee), 1 ether);
    }

                                                     
                                                        
                                                                          
    function removeFee(uint256 amount, uint256 fee) internal view returns (uint256){
        return SafeMath.div(SafeMath.mul(amount, 1 ether), SafeMath.add(fee, 1 ether));
    }
      
                                 
      

                                                                                       
                                                                                          
    function() public payable whenNotPaused {
                                                                           
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        if (size == 0) {
            errorReporter.revertTx("EOA cannot send ether to primary fallback");
        }
    }
}