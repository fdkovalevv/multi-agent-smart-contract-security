contract ERC223LegacyCallbackCompat {

                            
                       
                            

    function onTokenTransfer(address wallet, uint256 amount, bytes data)
        public
    {
        tokenFallback(wallet, amount, data);
    }

    function tokenFallback(address wallet, uint256 amount, bytes data)
        public;

}

contract KnownContracts {

                            
                
                            

                                                           
    bytes32 internal constant FEE_DISBURSAL_CONTROLLER = 0xfc72936b568fd5fc632b76e8feac0b717b4db1fce26a1b3b623b7fb6149bd8ae;

}

contract KnownInterfaces {

                            
                
                            

                                                               
                                                   
                                                     

                                                                                      
                                                                                                        

                                                                
    bytes4 internal constant KNOWN_INTERFACE_NEUMARK = 0xeb41a1bd;

                                                                  
    bytes4 internal constant KNOWN_INTERFACE_ETHER_TOKEN = 0x8cf73cf1;

                                                                
    bytes4 internal constant KNOWN_INTERFACE_EURO_TOKEN = 0x83c3790b;

                                                                               
    bytes4 internal constant KNOWN_INTERFACE_IDENTITY_REGISTRY = 0x0a72e073;

                                                                                          
    bytes4 internal constant KNOWN_INTERFACE_TOKEN_EXCHANGE_RATE_ORACLE = 0xc6e5349e;

                                                                       
    bytes4 internal constant KNOWN_INTERFACE_FEE_DISBURSAL = 0xf4c848e8;

                                                                                                         
    bytes4 internal constant KNOWN_INTERFACE_PLATFORM_PORTFOLIO = 0xaa1590d0;

                                                                         
    bytes4 internal constant KNOWN_INTERFACE_TOKEN_EXCHANGE = 0xddd7a521;

                                                                  
    bytes4 internal constant KNOWN_INTERFACE_GAS_EXCHANGE = 0x89dbc6de;

                                                                       
    bytes4 internal constant KNOWN_INTERFACE_ACCESS_POLICY = 0xb05049d9;

                                                                   
    bytes4 internal constant KNOWN_INTERFACE_EURO_LOCK = 0x2347a19e;

                                                                     
    bytes4 internal constant KNOWN_INTERFACE_ETHER_LOCK = 0x978a6823;

                                                                 
    bytes4 internal constant KNOWN_INTERFACE_ICBM_EURO_LOCK = 0x36021e14;

                                                                         
    bytes4 internal constant KNOWN_INTERFACE_ICBM_ETHER_LOCK = 0x0b58f006;

                                                                      
    bytes4 internal constant KNOWN_INTERFACE_ICBM_ETHER_TOKEN = 0xae8b50b9;

                                                                    
    bytes4 internal constant KNOWN_INTERFACE_ICBM_EURO_TOKEN = 0xc2c6cd72;

                                                                                    
    bytes4 internal constant KNOWN_INTERFACE_ICBM_COMMITMENT = 0x7f2795ef;

                                                                                      
    bytes4 internal constant KNOWN_INTERFACE_FORK_ARBITER = 0x2fe7778c;

                                                                         
    bytes4 internal constant KNOWN_INTERFACE_PLATFORM_TERMS = 0x75ecd7f8;

                                                                        
    bytes4 internal constant KNOWN_INTERFACE_UNIVERSE = 0xbf202454;

                                                                     
    bytes4 internal constant KNOWN_INTERFACE_COMMITMENT = 0xfa0e0c60;

                                                                                         
    bytes4 internal constant KNOWN_INTERFACE_EQUITY_TOKEN_CONTROLLER = 0xfa30b2f1;

                                                                    
    bytes4 internal constant KNOWN_INTERFACE_EQUITY_TOKEN = 0xab9885bb;

                                                            
    bytes4 internal constant KNOWN_INTERFACE_PAYMENT_TOKEN = 0xb2a0042a;
}

contract Math {

                            
                         
                            

                                     
    function absDiff(uint256 v1, uint256 v2)
        internal
        pure
        returns(uint256)
    {
        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

                                                          
    function divRound(uint256 v, uint256 d)
        internal
        pure
        returns(uint256)
    {
        return add(v, d/2) / d;
    }

                                                                                                        
                                                                                                                       
                                                                                      
                                     
    function decimalFraction(uint256 amount, uint256 frac)
        internal
        pure
        returns(uint256)
    {
                                               
        return proportion(amount, frac, 10**18);
    }

                                                                                  
                                              
    function proportion(uint256 amount, uint256 part, uint256 total)
        internal
        pure
        returns(uint256)
    {
        return divRound(mul(amount, part), total);
    }

      
                                       
      

    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a > b ? a : b;
    }
}

contract IERC677Callback {

                            
                       
                            

                                                                             
                                                                            
                                                                    
    function receiveApproval(
        address from,
        uint256 amount,
        address token,                
        bytes data
    )
        public
        returns (bool success);

}

contract IContractId {
                                  
                                             
    function contractId() public pure returns (bytes32 id, uint256 version);
}

contract IERC223Callback {

                            
                       
                            

    function tokenFallback(address from, uint256 amount, bytes data)
        public;

}

contract Serialization {

                            
                         
                            
    function decodeAddress(bytes b)
        internal
        pure
        returns (address a)
    {
        require(b.length == 20);
        assembly {
                                                                                               
            a := and(mload(add(b, 20)), 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
    }

    function decodeAddressUInt256(bytes b)
        internal
        pure
        returns (address a, uint256 i)
    {
        require(b.length == 52);
        assembly {
                                                                                               
            a := and(mload(add(b, 20)), 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            i := mload(add(b, 52))
        }
    }
}

contract IERC223LegacyCallback {

                            
                       
                            

    function onTokenTransfer(address from, uint256 amount, bytes data)
        public;

}

contract FeeDisbursal is
    IERC223Callback,
    IERC677Callback,
    IERC223LegacyCallback,
    ERC223LegacyCallbackCompat,
    Serialization,
    Math,
    KnownContracts,
    KnownInterfaces,
    IContractId
{

                            
             
                            

    event LogDisbursalCreated(
        address indexed proRataToken,
        address indexed token,
        uint256 amount,
        uint256 recycleAfterDuration,
        address disburser,
        uint256 index
    );

    event LogDisbursalAccepted(
        address indexed claimer,
        address token,
        address proRataToken,
        uint256 amount,
        uint256 nextIndex
    );

    event LogDisbursalRejected(
        address indexed claimer,
        address token,
        address proRataToken,
        uint256 amount,
        uint256 nextIndex
    );

    event LogFundsRecycled(
        address indexed proRataToken,
        address indexed token,
        uint256 amount,
        address by
    );

    event LogChangeFeeDisbursalController(
        address oldController,
        address newController,
        address by
    );

                            
            
                            
    struct Disbursal {
                                                                                                 
        uint256 snapshotId;
                                       
        uint256 amount;
                                                                     
        uint128 recycleableAfterTimestamp;
                                                  
        uint128 disbursalTimestamp;
                                         
        address disburser;
    }

                            
                
                            
    uint256 constant UINT256_MAX = 2**256 - 1;


                            
                      
                            
    Universe private UNIVERSE;

                                                              
    address private ICBM_ETHER_TOKEN;

                            
                    
                            

                          
    IFeeDisbursalController private _feeDisbursalController;
                                                                                                           
    mapping (address => mapping(address => Disbursal[])) private _disbursals;
                                                                                
                                                                                                                
    mapping (address => mapping(address => mapping(address => uint256))) _disbursalProgress;


                            
                  
                            
    constructor(Universe universe, IFeeDisbursalController controller)
        public
    {
        require(universe != address(0x0));
        (bytes32 controllerContractId, ) = controller.contractId();
        require(controllerContractId == FEE_DISBURSAL_CONTROLLER);
        UNIVERSE = universe;
        ICBM_ETHER_TOKEN = universe.getSingleton(KNOWN_INTERFACE_ICBM_ETHER_TOKEN);
        _feeDisbursalController = controller;
    }

                            
                       
                            

                                                                    
                                                     
                                                                                                                    
                                                 
    function getDisbursal(address token, address proRataToken, uint256 index)
        public
        constant
    returns (
        uint256 snapshotId,
        uint256 amount,
        uint256 recycleableAfterTimestamp,
        uint256 disburseTimestamp,
        address disburser
    )
    {
        Disbursal storage disbursal = _disbursals[token][proRataToken][index];
        snapshotId = disbursal.snapshotId;
        amount = disbursal.amount;
        recycleableAfterTimestamp = disbursal.recycleableAfterTimestamp;
        disburseTimestamp = disbursal.disbursalTimestamp;
        disburser = disbursal.disburser;
    }

                                                                                                     
                                                     
                                                                                                                    
                                                                                                                            
    function getNonClaimableDisbursals(address token, address proRataToken)
        public
        constant
    returns (uint256[3][] memory disbursals)
    {
        uint256 len = _disbursals[token][proRataToken].length;
        if (len == 0) {
            return;
        }
                                                  
        uint256 snapshotId = ITokenSnapshots(proRataToken).currentSnapshotId();
        uint256 ii = len;
        while(_disbursals[token][proRataToken][ii-1].snapshotId == snapshotId && --ii > 0) {}
        disbursals = new uint256[3][](len-ii);
        for(uint256 jj = 0; jj < len - ii; jj += 1) {
            disbursals[jj][0] = snapshotId;
            disbursals[jj][1] = _disbursals[token][proRataToken][ii+jj].amount;
            disbursals[jj][2] = ii+jj;
        }
    }

                                                       
                                                     
                                                                                                                    
    function getDisbursalCount(address token, address proRataToken)
        public
        constant
        returns (uint256)
    {
        return _disbursals[token][proRataToken].length;
    }

                                                                                                       
                                                     
                                                                                                                    
                                                                                                    
    function accept(address token, ITokenSnapshots proRataToken, uint256 until)
        public
    {
                                                                  
        require(_feeDisbursalController.onAccept(token, proRataToken, msg.sender), "NF_ACCEPT_REJECTED");
        (uint256 claimedAmount, , uint256 nextIndex) = claimPrivate(token, proRataToken, msg.sender, until);

                                       
        if (claimedAmount > 0) {
            IERC223Token ierc223Token = IERC223Token(token);
            assert(ierc223Token.transfer(msg.sender, claimedAmount, ""));
        }
              
        emit LogDisbursalAccepted(msg.sender, token, proRataToken, claimedAmount, nextIndex);
    }

                                                                                                 
                                                        
                                                                                                                    
    function acceptMultipleByToken(address[] tokens, ITokenSnapshots proRataToken)
        public
    {
        uint256[2][] memory claimed = new uint256[2][](tokens.length);
                                 
        uint256 i;
        for (i = 0; i < tokens.length; i += 1) {
                                                                      
            require(_feeDisbursalController.onAccept(tokens[i], proRataToken, msg.sender), "NF_ACCEPT_REJECTED");
            (claimed[i][0], ,claimed[i][1]) = claimPrivate(tokens[i], proRataToken, msg.sender, UINT256_MAX);
        }
                                                                                               
        for (i = 0; i < tokens.length; i += 1) {
            if (claimed[i][0] > 0) {
                                               
                IERC223Token ierc223Token = IERC223Token(tokens[i]);
                assert(ierc223Token.transfer(msg.sender, claimed[i][0], ""));
            }
                                             
            emit LogDisbursalAccepted(msg.sender, tokens[i], proRataToken, claimed[i][0], claimed[i][1]);
        }
    }

                                                                                
                                                     
                                                                                                                        
                                                                                                
    function acceptMultipleByProRataToken(address token, ITokenSnapshots[] proRataTokens)
        public
    {
        uint256 i;
        uint256 fullAmount;
        for (i = 0; i < proRataTokens.length; i += 1) {
            require(_feeDisbursalController.onAccept(token, proRataTokens[i], msg.sender), "NF_ACCEPT_REJECTED");
            (uint256 amount, , uint256 nextIndex) = claimPrivate(token, proRataTokens[i], msg.sender, UINT256_MAX);
            fullAmount += amount;
                                                                                       
            emit LogDisbursalAccepted(msg.sender, token, proRataTokens[i], amount, nextIndex);
        }
        if (fullAmount > 0) {
                                                                                                   
            IERC223Token ierc223Token = IERC223Token(token);
            assert(ierc223Token.transfer(msg.sender, fullAmount, ""));
        }
    }

                                                                                                  
                                                     
                                                                                                                    
                                                                                                    
    function reject(address token, ITokenSnapshots proRataToken, uint256 until)
        public
    {
                                                                  
        require(_feeDisbursalController.onReject(token, address(0), msg.sender), "NF_REJECT_REJECTED");
        (uint256 claimedAmount, , uint256 nextIndex) = claimPrivate(token, proRataToken, msg.sender, until);
                                             
        if (claimedAmount > 0) {
            PlatformTerms terms = PlatformTerms(UNIVERSE.platformTerms());
            disburse(token, this, claimedAmount, proRataToken, terms.DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION());
        }
              
        emit LogDisbursalRejected(msg.sender, token, proRataToken, claimedAmount, nextIndex);
    }

                                                                                    
                                                     
                                                                                                                    
                                                                          
                                                                                                    
                                                                                                                               
    function claimable(address token, ITokenSnapshots proRataToken, address claimer, uint256 until)
        public
        constant
    returns (uint256 claimableAmount, uint256 totalAmount, uint256 recycleableAfterTimestamp, uint256 firstIndex)
    {
        firstIndex = _disbursalProgress[token][proRataToken][claimer];
        if (firstIndex < _disbursals[token][proRataToken].length) {
            recycleableAfterTimestamp = _disbursals[token][proRataToken][firstIndex].recycleableAfterTimestamp;
        }
                                                                                                                 
        (claimableAmount, totalAmount,) = claimablePrivate(token, proRataToken, claimer, until, false);
    }

                                                                                         
                                                        
                                                                                                                    
                                                                          
                                                                                                                                        
                                                                              
    function claimableMutipleByToken(address[] tokens, ITokenSnapshots proRataToken, address claimer)
        public
        constant
    returns (uint256[4][] claimables)
    {
        claimables = new uint256[4][](tokens.length);
        for (uint256 i = 0; i < tokens.length; i += 1) {
            claimables[i][3] = _disbursalProgress[tokens[i]][proRataToken][claimer];
            if (claimables[i][3] < _disbursals[tokens[i]][proRataToken].length) {
                claimables[i][2] = _disbursals[tokens[i]][proRataToken][claimables[i][3]].recycleableAfterTimestamp;
            }
            (claimables[i][0], claimables[i][1], ) = claimablePrivate(tokens[i], proRataToken, claimer, UINT256_MAX, false);
        }
    }

                                                                                 
                                                     
                                                                                                                        
                                                                          
                                                                                                                                        
    function claimableMutipleByProRataToken(address token, ITokenSnapshots[] proRataTokens, address claimer)
        public
        constant
    returns (uint256[4][] claimables)
    {
        claimables = new uint256[4][](proRataTokens.length);
        for (uint256 i = 0; i < proRataTokens.length; i += 1) {
            claimables[i][3] = _disbursalProgress[token][proRataTokens[i]][claimer];
            if (claimables[i][3] < _disbursals[token][proRataTokens[i]].length) {
                claimables[i][2] = _disbursals[token][proRataTokens[i]][claimables[i][3]].recycleableAfterTimestamp;
            }
            (claimables[i][0], claimables[i][1], ) = claimablePrivate(token, proRataTokens[i], claimer, UINT256_MAX, false);
        }
    }

                                                      
                                                    
                                                                                                                    
                                                                        
                                                   
    function recycle(address token, ITokenSnapshots proRataToken, address[] investors, uint256 until)
        public
    {
        require(_feeDisbursalController.onRecycle(token, proRataToken, investors, until), "");
                                                                                  
                                                   
        uint256 totalClaimableAmount = 0;
        for (uint256 i = 0; i < investors.length; i += 1) {
            (uint256 claimableAmount, ,uint256 nextIndex) = claimablePrivate(token, ITokenSnapshots(proRataToken), investors[i], until, true);
            totalClaimableAmount += claimableAmount;
            _disbursalProgress[token][proRataToken][investors[i]] = nextIndex;
        }

                                        
        if (totalClaimableAmount > 0) {
                                                       
            PlatformTerms terms = PlatformTerms(UNIVERSE.platformTerms());
            disburse(token, this, totalClaimableAmount, proRataToken, terms.DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION());
        }

              
        emit LogFundsRecycled(proRataToken, token, totalClaimableAmount, msg.sender);
    }

                                                                    
                                                    
                                                                                                                    
                                                                        
                                                   
    function recycleable(address token, ITokenSnapshots proRataToken, address[] investors, uint256 until)
        public
        constant
    returns (uint256)
    {
                                                                                  
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < investors.length; i += 1) {
            (uint256 claimableAmount,,) = claimablePrivate(token, proRataToken, investors[i], until, true);
            totalAmount += claimableAmount;
        }
        return totalAmount;
    }

                                      
    function feeDisbursalController()
        public
        constant
        returns (IFeeDisbursalController)
    {
        return _feeDisbursalController;
    }

                                         
    function changeFeeDisbursalController(IFeeDisbursalController newController)
        public
    {
        require(_feeDisbursalController.onChangeFeeDisbursalController(msg.sender, newController), "NF_CHANGING_CONTROLLER_REJECTED");
        address oldController = address(_feeDisbursalController);
        _feeDisbursalController = newController;
        emit LogChangeFeeDisbursalController(oldController, address(newController), msg.sender);
    }

                                                                                     

    function tokenFallback(address wallet, uint256 amount, bytes data)
        public
    {
        tokenFallbackPrivate(msg.sender, wallet, amount, data);
    }

                                                                                   
    function receiveApproval(address from, uint256 amount, address tokenAddress, bytes data)
        public
        returns (bool success)
    {
                               
        require(msg.sender == tokenAddress);
                          
        IERC20Token token = IERC20Token(tokenAddress);
                                                                     
        require(token.transferFrom(from, address(this), amount));

                                                 
                                                                                                                                          
        if (tokenAddress == ICBM_ETHER_TOKEN) {
                                                                      
            IWithdrawableToken(tokenAddress).withdraw(amount);
            token = IERC20Token(UNIVERSE.etherToken());
            EtherToken(token).deposit.value(amount)();
        }
        if(tokenAddress == UNIVERSE.getSingleton(KNOWN_INTERFACE_ICBM_EURO_TOKEN)) {
            IWithdrawableToken(tokenAddress).withdraw(amount);
            token = IERC20Token(UNIVERSE.euroToken());
                                                           
            EuroToken(token).deposit(this, amount, 0x0);
        }
        tokenFallbackPrivate(address(token), from, amount, data);
        return true;
    }

      
                                 
      

    function contractId()
        public
        pure
        returns (bytes32 id, uint256 version)
    {
        return (0x2e1a7e4ac88445368dddb31fe43d29638868837724e9be8ffd156f21a971a4d7, 0);
    }

      
                                                                 
      
    function ()
        public
        payable
    {
        require(msg.sender == ICBM_ETHER_TOKEN);
    }


                            
                        
                            

    function tokenFallbackPrivate(address token, address wallet, uint256 amount, bytes data)
        private
    {
        ITokenSnapshots proRataToken;
        PlatformTerms terms = PlatformTerms(UNIVERSE.platformTerms());
        uint256 recycleAfterDuration = terms.DEFAULT_DISBURSAL_RECYCLE_AFTER_DURATION();
        if (data.length == 20) {
            proRataToken = ITokenSnapshots(decodeAddress(data));
        }
        else if (data.length == 52) {
            address proRataTokenAddress;
            (proRataTokenAddress, recycleAfterDuration) = decodeAddressUInt256(data);
            proRataToken = ITokenSnapshots(proRataTokenAddress);
        } else {
                                                                                                                
            proRataToken = UNIVERSE.neumark();
        }
        disburse(token, wallet, amount, proRataToken, recycleAfterDuration);
    }

                                      
                                                     
                                                                              
                                                      
                                                                          
    function disburse(address token, address disburser, uint256 amount, ITokenSnapshots proRataToken, uint256 recycleAfterDuration)
        private
    {
        require(
            _feeDisbursalController.onDisburse(token, disburser, amount, address(proRataToken), recycleAfterDuration), "NF_DISBURSAL_REJECTED");

        uint256 snapshotId = proRataToken.currentSnapshotId();
        uint256 proRataTokenTotalSupply = proRataToken.totalSupplyAt(snapshotId);
                                                                         
        if (token == address(proRataToken)) {
            proRataTokenTotalSupply -= proRataToken.balanceOfAt(address(this), snapshotId);
        }
        require(proRataTokenTotalSupply > 0, "NF_NO_DISBURSE_EMPTY_TOKEN");
        uint256 recycleAfter = add(block.timestamp, recycleAfterDuration);
        assert(recycleAfter<2**128);

        Disbursal[] storage disbursals = _disbursals[token][proRataToken];
                                                  
        bool merged = false;
        for ( uint256 i = disbursals.length - 1; i != UINT256_MAX; i-- ) {
                                                                
                                                                                            
            Disbursal storage disbursal = disbursals[i];
            if ( disbursal.snapshotId < snapshotId) {
                break;
            }
                                                                                          
                                                                                        
            if ( disbursal.disburser == disburser ) {
                merged = true;
                disbursal.amount += amount;
                disbursal.recycleableAfterTimestamp = uint128(recycleAfter);
                disbursal.disbursalTimestamp = uint128(block.timestamp);
                break;
            }
        }

                                       
        if (!merged) {
            disbursals.push(Disbursal({
                recycleableAfterTimestamp: uint128(recycleAfter),
                disbursalTimestamp: uint128(block.timestamp),
                amount: amount,
                snapshotId: snapshotId,
                disburser: disburser
            }));
        }
        emit LogDisbursalCreated(proRataToken, token, amount, recycleAfterDuration, disburser, merged ? i : disbursals.length - 1);
    }


                                                                                  
                                                     
                                                                         
                                                 
    function claimPrivate(address token, ITokenSnapshots proRataToken, address claimer, uint256 until)
        private
    returns (uint256 claimedAmount, uint256 totalAmount, uint256 nextIndex)
    {
        (claimedAmount, totalAmount, nextIndex) = claimablePrivate(token, proRataToken, claimer, until, false);

                                          
        _disbursalProgress[token][proRataToken][claimer] = nextIndex;
    }

                                                                               
                                                     
                                                                         
                                                                          
                                                                               
                                                                                                       
    function claimablePrivate(address token, ITokenSnapshots proRataToken, address claimer, uint256 until, bool onlyRecycleable)
        private
        constant
        returns (uint256 claimableAmount, uint256 totalAmount, uint256 nextIndex)
    {
        nextIndex = min(until, _disbursals[token][proRataToken].length);
        uint256 currentIndex = _disbursalProgress[token][proRataToken][claimer];
        uint256 currentSnapshotId = proRataToken.currentSnapshotId();
        for (; currentIndex < nextIndex; currentIndex += 1) {
            Disbursal storage disbursal = _disbursals[token][proRataToken][currentIndex];
            uint256 snapshotId = disbursal.snapshotId;
                                                              
            if ( snapshotId == currentSnapshotId )
                break;
                                                                                         
                                                                                                                                
                                                                                                         
            if ( onlyRecycleable && disbursal.recycleableAfterTimestamp > block.timestamp )
                break;
                                  
            totalAmount += disbursal.amount;
                                   
            claimableAmount += calculateClaimableAmount(claimer, disbursal.amount, token, proRataToken, snapshotId);
        }
        return (claimableAmount, totalAmount, currentIndex);
    }

    function calculateClaimableAmount(address claimer, uint256 disbursalAmount, address token, ITokenSnapshots proRataToken, uint256 snapshotId)
        private
        constant
        returns (uint256)
    {
        uint256 proRataClaimerBalance = proRataToken.balanceOfAt(claimer, snapshotId);
                                      
        if (proRataClaimerBalance == 0) {
            return 0;
        }
                                  
        uint256 proRataTokenTotalSupply = proRataToken.totalSupplyAt(snapshotId);
                                                                                                                         
        if (token == address(proRataToken)) {
            proRataTokenTotalSupply -= proRataToken.balanceOfAt(address(this), snapshotId);
        }
                                                                                                              
                                                                                                        
                                                                                         
                                                                                         
                                                                                     
        return mul(disbursalAmount, proRataClaimerBalance) / proRataTokenTotalSupply;
    }
}