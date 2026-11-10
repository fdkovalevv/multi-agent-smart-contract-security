contract Owned {
    address public owner;
    address public nominatedOwner;

    function Owned(address _owner)
        public
    {
        owner = _owner;
    }

    function nominateOwner(address _owner)
        external
        onlyOwner
    {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership()
        external
    {
        require(msg.sender == nominatedOwner);
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

contract Proxyable is Owned {
                                             
    Proxy public proxy;

                                                                
                                                                             
                                                                                 
    address messageSender;

    function Proxyable(address _owner)
        Owned(_owner)
        public { }

    function setProxy(Proxy _proxy)
        external
        onlyOwner
    {
        proxy = _proxy;
        emit ProxyChanged(_proxy);
    }

    function setMessageSender(address sender)
        external
        onlyProxy
    {
        messageSender = sender;
    }

    modifier onlyProxy
    {
        require(Proxy(msg.sender) == proxy);
        _;
    }

    modifier onlyOwner_Proxy
    {
        require(messageSender == owner);
        _;
    }

    modifier optionalProxy
    {
        if (Proxy(msg.sender) != proxy) {
            messageSender = msg.sender;
        }
        _;
    }

                                                               
                                                                                  
    modifier optionalProxy_onlyOwner
    {
        if (Proxy(msg.sender) != proxy) {
            messageSender = msg.sender;
        }
        require(messageSender == owner);
        _;
    }

    event ProxyChanged(address proxyAddress);

}

contract SafeDecimalMath {

                                                      
    uint8 public constant decimals = 18;

                                   
    uint public constant UNIT = 10 ** uint(decimals);

                                                    
    function addIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return x + y >= y;
    }

                                                                                         
    function safeAdd(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(x + y >= y);
        return x + y;
    }

                                                                                    
    function subIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y <= x;
    }

                                                                                               
    function safeSub(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        require(y <= x);
        return x - y;
    }

                                                          
    function mulIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        if (x == 0) {
            return true;
        }
        return (x * y) / x == y;
    }

                                                                                             
    function safeMul(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        if (x == 0) {
            return 0;
        }
        uint p = x * y;
        require(p / x == y);
        return p;
    }

                                                                                         
                                                                                        
                                                                                           
       
                                                                                                            
                                                                                            
                                                                                                               
                                                                                         
                                             
       
    function safeMul_dec(uint x, uint y)
        pure
        internal
        returns (uint)
    {
                                                                               
                     
        return safeMul(x, y) / UNIT;

    }

                                                     
    function divIsSafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y != 0;
    }

                                                                                             
    function safeDiv(uint x, uint y)
        pure
        internal
        returns (uint)
    {
                                                                
                                                                         
                                                                                
        require(y != 0);
        return x / y;
    }

                                                                                                      
                                                                                                 
                                                                                    
    function safeDiv_dec(uint x, uint y)
        pure
        internal
        returns (uint)
    {
                                                                     
        return safeDiv(safeMul(x, UNIT), y);
    }

                                                                     
                                                                 
    function intToDec(uint i)
        pure
        internal
        returns (uint)
    {
        return safeMul(i, UNIT);
    }
}

contract ExternStateProxyFeeToken is Proxyable, SafeDecimalMath {

                                               

                                      
    TokenState public state;

                         
    string public name;
    string public symbol;
    uint public totalSupply;

                                                 
    uint public transferFeeRate;
                              
    uint constant MAX_TRANSFER_FEE_RATE = UNIT / 10;
                                                         
    address public feeAuthority;


                                           

    function ExternStateProxyFeeToken(string _name, string _symbol,
                                      uint _transferFeeRate, address _feeAuthority,
                                      TokenState _state, address _owner)
        Proxyable(_owner)
        public
    {
        if (_state == TokenState(0)) {
            state = new TokenState(_owner, address(this));
        } else {
            state = _state;
        }

        name = _name;
        symbol = _symbol;
        transferFeeRate = _transferFeeRate;
        feeAuthority = _feeAuthority;
    }

                                       

    function setTransferFeeRate(uint _transferFeeRate)
        external
        optionalProxy_onlyOwner
    {
        require(_transferFeeRate <= MAX_TRANSFER_FEE_RATE);
        transferFeeRate = _transferFeeRate;
        emit TransferFeeRateUpdated(_transferFeeRate);
    }

    function setFeeAuthority(address _feeAuthority)
        external
        optionalProxy_onlyOwner
    {
        feeAuthority = _feeAuthority;
        emit FeeAuthorityUpdated(_feeAuthority);
    }

    function setState(TokenState _state)
        external
        optionalProxy_onlyOwner
    {
        state = _state;
        emit StateUpdated(_state);
    }

                                     

    function balanceOf(address account)
        public
        view
        returns (uint)
    {
        return state.balanceOf(account);
    }

    function allowance(address from, address to)
        public
        view
        returns (uint)
    {
        return state.allowance(from, to);
    }

                                                                                 
    function transferFeeIncurred(uint value)
        public
        view
        returns (uint)
    {
        return safeMul_dec(value, transferFeeRate);
                                                                                                       
                                                                                             
                                                                                             
                                                       
                                  
                 
                           
    }

                                                                           
                         
    function transferPlusFee(uint value)
        external
        view
        returns (uint)
    {
        return safeAdd(value, transferFeeIncurred(value));
    }

                                                                                      
    function priceToSpend(uint value)
        external
        view
        returns (uint)
    {
        return safeDiv_dec(value, safeAdd(UNIT, transferFeeRate));
    }

                                                                
                                                          
    function feePool()
        external
        view
        returns (uint)
    {
        return state.balanceOf(address(this));
    }


                                                  

                                                                                      
                                    
    function _transfer_byProxy(address sender, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

                                                                        
                                    
        uint fee = transferFeeIncurred(value);
        uint totalCharge = safeAdd(value, fee);

                                                                        
        state.setBalanceOf(sender, safeSub(state.balanceOf(sender), totalCharge));
        state.setBalanceOf(to, safeAdd(state.balanceOf(to), value));
        state.setBalanceOf(address(this), safeAdd(state.balanceOf(address(this)), fee));

        emit Transfer(sender, to, value);
        emit TransferFeePaid(sender, fee);
        emit Transfer(sender, address(this), fee);

        return true;
    }

                                                                                      
                                    
    function _transferFrom_byProxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

                                                                        
                                    
        uint fee = transferFeeIncurred(value);
        uint totalCharge = safeAdd(value, fee);

                                                                        
        state.setBalanceOf(from, safeSub(state.balanceOf(from), totalCharge));
        state.setAllowance(from, sender, safeSub(state.allowance(from, sender), totalCharge));
        state.setBalanceOf(to, safeAdd(state.balanceOf(to), value));
        state.setBalanceOf(address(this), safeAdd(state.balanceOf(address(this)), fee));

        emit Transfer(from, to, value);
        emit TransferFeePaid(sender, fee);
        emit Transfer(from, address(this), fee);

        return true;
    }

    function approve(address spender, uint value)
        external
        optionalProxy
        returns (bool)
    {
        address sender = messageSender;
        state.setAllowance(sender, spender, value);

        emit Approval(sender, spender, value);

        return true;
    }

                                                                 
    function withdrawFee(address account, uint value)
        external
        returns (bool)
    {
        require(msg.sender == feeAuthority && account != address(0));
        
                                          
        if (value == 0) {
            return false;
        }

                                                                                          
        state.setBalanceOf(address(this), safeSub(state.balanceOf(address(this)), value));
        state.setBalanceOf(account, safeAdd(state.balanceOf(account), value));

        emit FeesWithdrawn(account, account, value);
        emit Transfer(address(this), account, value);

        return true;
    }

                                                                    
    function donateToFeePool(uint n)
        external
        optionalProxy
        returns (bool)
    {
        address sender = messageSender;

                                          
        uint balance = state.balanceOf(sender);
        require(balance != 0);

                                                            
        state.setBalanceOf(sender, safeSub(balance, n));
        state.setBalanceOf(address(this), safeAdd(state.balanceOf(address(this)), n));

        emit FeesDonated(sender, sender, n);
        emit Transfer(sender, address(this), n);

        return true;
    }

                                      

    event Transfer(address indexed from, address indexed to, uint value);

    event TransferFeePaid(address indexed account, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

    event TransferFeeRateUpdated(uint newFeeRate);

    event FeeAuthorityUpdated(address feeAuthority);

    event StateUpdated(address newState);

    event FeesWithdrawn(address account, address indexed accountIndex, uint value);

    event FeesDonated(address donor, address indexed donorIndex, uint value);
}

contract EtherNomin is ExternStateProxyFeeToken {

                                               

                                                              
                                                   
    address public oracle;

                                                                    
    Court public court;

                                                             
    address public beneficiary;

                                           
    uint public nominPool;

                                                                                 
    uint public poolFeeRate = UNIT / 200;

                                                            
    uint constant MINIMUM_PURCHASE = UNIT / 100;

                                                                     
    uint constant MINIMUM_ISSUANCE_RATIO =  2 * UNIT;

                                                                             
                                     
    uint constant AUTO_LIQUIDATION_RATIO = UNIT;

                                                                                                       
                                                 
    uint constant DEFAULT_LIQUIDATION_PERIOD = 90 days;
    uint constant MAX_LIQUIDATION_PERIOD = 180 days;
    uint public liquidationPeriod = DEFAULT_LIQUIDATION_PERIOD;

                                                                          
                                                                     
                                            
    uint public liquidationTimestamp = ~uint(0);

                                                
    uint public etherPrice;

                                       
    uint public lastPriceUpdate;

                                                                
                                                                            
    uint public stalePeriod = 2 days;

                                                                    
    mapping(address => bool) public frozen;


                                           

    function EtherNomin(address _havven, address _oracle,
                        address _beneficiary,
                        uint initialEtherPrice,
                        address _owner, TokenState initialState)
        ExternStateProxyFeeToken("Ether-Backed USD Nomins", "eUSD",
                                 15 * UNIT / 10000,                                     
                                 _havven,                                            
                                 initialState,
                                 _owner)
        public
    {
        oracle = _oracle;
        beneficiary = _beneficiary;

        etherPrice = initialEtherPrice;
        lastPriceUpdate = now;
        emit PriceUpdated(etherPrice);

                                                                              
        frozen[this] = true;
    }


                                       

    function setOracle(address _oracle)
        external
        optionalProxy_onlyOwner
    {
        oracle = _oracle;
        emit OracleUpdated(_oracle);
    }

    function setCourt(Court _court)
        external
        optionalProxy_onlyOwner
    {
        court = _court;
        emit CourtUpdated(_court);
    }

    function setBeneficiary(address _beneficiary)
        external
        optionalProxy_onlyOwner
    {
        beneficiary = _beneficiary;
        emit BeneficiaryUpdated(_beneficiary);
    }

    function setPoolFeeRate(uint _poolFeeRate)
        external
        optionalProxy_onlyOwner
    {
        require(_poolFeeRate <= UNIT);
        poolFeeRate = _poolFeeRate;
        emit PoolFeeRateUpdated(_poolFeeRate);
    }

    function setStalePeriod(uint _stalePeriod)
        external
        optionalProxy_onlyOwner
    {
        stalePeriod = _stalePeriod;
        emit StalePeriodUpdated(_stalePeriod);
    }
 

                                               

                                                             
                                     
                                        
    function fiatValue(uint eth)
        public
        view
        priceNotStale
        returns (uint)
    {
        return safeMul_dec(eth, etherPrice);
    }

                                                               
                                        
    function fiatBalance()
        public
        view
        returns (uint)
    {
                                                                     
        return fiatValue(address(this).balance);
    }

                                                              
                                    
                                        
    function etherValue(uint fiat)
        public
        view
        priceNotStale
        returns (uint)
    {
        return safeDiv_dec(fiat, etherPrice);
    }

                                                                      
    function etherValueAllowStale(uint fiat) 
        internal
        view
        returns (uint)
    {
        return safeDiv_dec(fiat, etherPrice);
    }

                                                        
                                        
    function collateralisationRatio()
        public
        view
        returns (uint)
    {
        return safeDiv_dec(fiatBalance(), _nominCap());
    }

                                                  
                                                                  
    function _nominCap()
        internal
        view
        returns (uint)
    {
        return safeAdd(nominPool, totalSupply);
    }

                                                                   
    function poolFeeIncurred(uint n)
        public
        view
        returns (uint)
    {
        return safeMul_dec(n, poolFeeRate);
    }

                                                                   
                                                    
    function purchaseCostFiat(uint n)
        public
        view
        returns (uint)
    {
        return safeAdd(n, poolFeeIncurred(n));
    }

                                                                    
                                        
    function purchaseCostEther(uint n)
        public
        view
        returns (uint)
    {
                                                                      
        return etherValue(purchaseCostFiat(n));
    }

                                                                   
                                                
    function saleProceedsFiat(uint n)
        public
        view
        returns (uint)
    {
        return safeSub(n, poolFeeIncurred(n));
    }

                                                            
              
                                        
    function saleProceedsEther(uint n)
        public
        view
        returns (uint)
    {
                                                                      
        return etherValue(saleProceedsFiat(n));
    }

                                                                             
    function saleProceedsEtherAllowStale(uint n)
        internal
        view
        returns (uint)
    {
        return etherValueAllowStale(saleProceedsFiat(n));
    }

                                                                  
                                                            
    function priceIsStale()
        public
        view
        returns (bool)
    {
        return safeAdd(lastPriceUpdate, stalePeriod) < now;
    }

    function isLiquidating()
        public
        view
        returns (bool)
    {
        return liquidationTimestamp <= now;
    }

                                                  
                                                                          
                                                                          
                                          
                                                                              
                                                               
    function canSelfDestruct()
        public
        view
        returns (bool)
    {
                                                                                             
                                                               
        if (isLiquidating()) {
                                                                                              
                               
            bool totalPeriodElapsed = liquidationTimestamp + liquidationPeriod < now;
                                                                            
            bool allTokensReturned = (liquidationTimestamp + 1 weeks < now) && (totalSupply == 0);
            return totalPeriodElapsed || allTokensReturned;
        }
        return false;
    }


                                                  

                                                         
                                                                  
                                                                
                                                       
                                                   
    function transfer(address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transfer_byProxy(messageSender, to, value);
    }

                                                             
                                                  
    function transferFrom(address from, address to, uint value)
        public
        optionalProxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transferFrom_byProxy(messageSender, from, to, value);
    }

                                                                       
                                      
                                                                               
                                                     
                              
                                    
                                               
    function updatePrice(uint price, uint timeSent)
        external
        postCheckAutoLiquidate
    {
                                                 
        require(msg.sender == oracle);
                                                                               
                                                                                       
        require(lastPriceUpdate < timeSent && timeSent < now + 10 minutes);

        etherPrice = price;
        lastPriceUpdate = timeSent;
        emit PriceUpdated(price);
    }

                                                                     
                                                
                              
                                        
                                                                                                           
                             
    function replenishPool(uint n)
        external
        payable
        notLiquidating
        optionalProxy_onlyOwner
    {
                                                                       
                                                                                                       
                                                                           
        require(fiatBalance() >= safeMul_dec(safeAdd(_nominCap(), n), MINIMUM_ISSUANCE_RATIO));
        nominPool = safeAdd(nominPool, n);
        emit PoolReplenished(n, msg.value);
    }

                                    
                              
                                        
                                                        
    function diminishPool(uint n)
        external
        optionalProxy_onlyOwner
    {
                                                                              
        require(nominPool >= n);
        nominPool = safeSub(nominPool, n);
        emit PoolDiminished(n);
    }

                                                                  
                                      
                              
                                                   
                                                      
                                                 
                                   
                             
    function buy(uint n)
        external
        payable
        notLiquidating
        optionalProxy
    {
                                                                             
        require(n >= MINIMUM_PURCHASE &&
                msg.value == purchaseCostEther(n));
        address sender = messageSender;
                                           
        nominPool = safeSub(nominPool, n);
        state.setBalanceOf(sender, safeAdd(state.balanceOf(sender), n));
        emit Purchased(sender, sender, n, msg.value);
        emit Transfer(0, sender, n);
        totalSupply = safeAdd(totalSupply, n);
    }

                                                                  
                                       
                              
                                                  
                                                        
                                                   
    function sell(uint n)
        external
        optionalProxy
    {

                                                                             
                                                                      
                                               
        uint proceeds;
        if (isLiquidating()) {
            proceeds = saleProceedsEtherAllowStale(n);
        } else {
            proceeds = saleProceedsEther(n);
        }

        require(address(this).balance >= proceeds);

        address sender = messageSender;
                                                          
        state.setBalanceOf(sender, safeSub(state.balanceOf(sender), n));
        nominPool = safeAdd(nominPool, n);
        emit Sold(sender, sender, n, proceeds);
        emit Transfer(sender, 0, n);
        totalSupply = safeSub(totalSupply, n);
        sender.transfer(proceeds);
    }

                                                                               
                                                                                         
                                                                                    
                                                                
                         
                                        
                                              
    function forceLiquidation()
        external
        notLiquidating
        optionalProxy_onlyOwner
    {
        beginLiquidation();
    }

    function beginLiquidation()
        internal
    {
        liquidationTimestamp = now;
        emit LiquidationBegun(liquidationPeriod);
    }

                                                                                   
                                                                           
                              
    function extendLiquidationPeriod(uint extension)
        external
        optionalProxy_onlyOwner
    {
        require(isLiquidating());
        uint sum = safeAdd(liquidationPeriod, extension);
        require(sum <= MAX_LIQUIDATION_PERIOD);
        liquidationPeriod = sum;
        emit LiquidationExtended(extension);
    }

                                                                     
                                                                     
                                                               
                                                           
    function terminateLiquidation()
        external
        payable
        priceNotStale
        optionalProxy_onlyOwner
    {
        require(isLiquidating());
        require(_nominCap() == 0 || collateralisationRatio() >= AUTO_LIQUIDATION_RATIO);
        liquidationTimestamp = ~uint(0);
        liquidationPeriod = DEFAULT_LIQUIDATION_PERIOD;
        emit LiquidationTerminated();
    }

                                                                                       
                                                                
                                                                     
                                                   
    function selfDestruct()
        external
        optionalProxy_onlyOwner
    {
        require(canSelfDestruct());
        emit SelfDestructed(beneficiary);
        selfdestruct(beneficiary);
    }

                                                                             
                                                                                 
                                                               
    function confiscateBalance(address target)
        external
    {
                                                             
        require(Court(msg.sender) == court);
        
                                              
        uint motionID = court.targetMotionID(target);
        require(motionID != 0);

                                                 
                                                                       
                                           
        require(court.motionConfirming(motionID));
        require(court.motionPasses(motionID));
        require(!frozen[target]);

                                                               
        uint balance = state.balanceOf(target);
        state.setBalanceOf(address(this), safeAdd(state.balanceOf(address(this)), balance));
        state.setBalanceOf(target, 0);
        frozen[target] = true;
        emit AccountFrozen(target, target, balance);
        emit Transfer(target, address(this), balance);
    }

                                                               
                                           
    function unfreezeAccount(address target)
        external
        optionalProxy_onlyOwner
    {
        if (frozen[target] && EtherNomin(target) != this) {
            frozen[target] = false;
            emit AccountUnfrozen(target, target);
        }
    }

                                                                             
                                              
    function() public payable {}


                                         

    modifier notLiquidating
    {
        require(!isLiquidating());
        _;
    }

    modifier priceNotStale
    {
        require(!priceIsStale());
        _;
    }

                                                                 
                                                       
                                                                                   
                                                                       
                                                                                         
                                                                                                 
                                                                                             
                                            
                                                                         
    modifier postCheckAutoLiquidate
    {
        _;
        if (!isLiquidating() && _nominCap() != 0 && collateralisationRatio() < AUTO_LIQUIDATION_RATIO) {
            beginLiquidation();
        }
    }


                                      

    event PoolReplenished(uint nominsCreated, uint collateralDeposited);

    event PoolDiminished(uint nominsDestroyed);

    event Purchased(address buyer, address indexed buyerIndex, uint nomins, uint eth);

    event Sold(address seller, address indexed sellerIndex, uint nomins, uint eth);

    event PriceUpdated(uint newPrice);

    event StalePeriodUpdated(uint newPeriod);

    event OracleUpdated(address newOracle);

    event CourtUpdated(address newCourt);

    event BeneficiaryUpdated(address newBeneficiary);

    event LiquidationBegun(uint duration);

    event LiquidationTerminated();

    event LiquidationExtended(uint extension);

    event PoolFeeRateUpdated(uint newFeeRate);

    event SelfDestructed(address beneficiary);

    event AccountFrozen(address target, address indexed targetIndex, uint balance);

    event AccountUnfrozen(address target, address indexed targetIndex);
}