contract DutchAuction {

      
              
       
    event BidSubmission(address indexed sender, uint256 amount);

      
                 
       
    uint constant public MAX_TOKENS_SOLD = 5000000 * 10**18;      
    uint constant public WAITING_PERIOD = 7 days;

      
               
       
    Token public virtuePlayerPoints;
    address public wallet;
    address public owner;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;
    
                                                                       
                                                                        
                
    
    address[] public bidderWhitelist;                                               
    mapping (address => uint ) public whitelistIndexMap;                               

      
             
       
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

      
                 
       
    modifier atStage(Stages _stage) {
        require (stage == _stage);
                                                 
        _;
    }

    modifier isOwner() {
        require (msg.sender == owner);
                                               
        _;
    }

    modifier isWallet() {
        require (msg.sender == wallet);
                                                
        _;
    }

    modifier isValidPayload() {
        require (msg.data.length == 4 || msg.data.length == 36);
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }

      
                        
       
                                                      
                                                            
                                        
                                                 
    function DutchAuction(address _wallet, uint _ceiling, uint _priceFactor)
        public
    {
        require (_wallet != 0);
        require (_ceiling != 0);
        require (_priceFactor != 0);
                                        
        owner = msg.sender;
        wallet = _wallet;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

                                                               
                                                          
    function setup(address _virtuePlayerPoints)
        public
        isOwner
        atStage(Stages.AuctionDeployed)
    {
        require (_virtuePlayerPoints != 0);
                                       
        virtuePlayerPoints = Token(_virtuePlayerPoints);
                                 
        require (virtuePlayerPoints.balanceOf(this) == MAX_TOKENS_SOLD);

        stage = Stages.AuctionSetUp;
    }


                                            
                                             
    function addToWhitelist(address _bidderAddr)
        public
        isOwner
        atStage(Stages.AuctionSetUp)
    {
        require(_bidderAddr != 0);
        if (whitelistIndexMap[_bidderAddr] == 0)
        {
            uint idxPlusOne = bidderWhitelist.push(_bidderAddr);
            whitelistIndexMap[_bidderAddr] = idxPlusOne; 
        }
    }

                                                       
                                                         
    function addArrayToWhitelist(address[] _bidderAddrs)
        public
        isOwner
        atStage(Stages.AuctionSetUp)
    {
        require(_bidderAddrs.length != 0);
        for(uint idx = 0; idx<_bidderAddrs.length; idx++) {
            addToWhitelist(_bidderAddrs[idx]);
        }
    }

                                                 
                                             
    function removeFromWhitelist(address _bidderAddr)
        public
        isOwner
        atStage(Stages.AuctionSetUp)       
    {
        require(_bidderAddr != 0);
        require( whitelistIndexMap[_bidderAddr] != 0);                                    
        uint idx = whitelistIndexMap[_bidderAddr] - 1;
        bidderWhitelist[idx] = 0;
        whitelistIndexMap[_bidderAddr] = 0;
    }
    
                                             
                                           
    function isInWhitelist(address _addr)
        public
        constant
        returns(bool)
    {
        return (whitelistIndexMap[_addr] != 0);
    }
    
                                                    
                                          
    function whitelistCount()
        public
        constant
        returns (uint)        
    {
        uint count = 0;
        for (uint i = 0; i< bidderWhitelist.length; i++) {
            if (bidderWhitelist[i] != 0)
                count++;
        }
        return count;
    }
    
                                       
                                       
                                                    
                                         
                                                                             
                                                                              
    function whitelistEntries(uint _startIdx, uint _count)
        public
        constant
        returns (address[])        
    {
        uint addrCount = whitelistCount();
        if (_count == 0)
            _count = addrCount; 
        if (_startIdx >= addrCount) {
            _startIdx = 0;
            _count = 0;
        } else if (_startIdx + _count > addrCount) {
            _count = addrCount - _startIdx;        
        }

        address[] memory results = new address[](_count);
                           
        uint dynArrayIdx = 0; 
        while (_startIdx > 0) {
            if (bidderWhitelist[dynArrayIdx++] != 0)
                _startIdx--;  
        }   
                            
        uint resultsIdx = 0; 
        while (resultsIdx < _count) {
            address addr = bidderWhitelist[dynArrayIdx++];
            if (addr != 0)
                results[resultsIdx++] = addr;      
        }
        return results;    
    }    
    
                                                
    function startAuction()
        public
        isWallet
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }

                                                                                      
                                                
                                                       
    function changeSettings(uint _ceiling, uint _priceFactor)
        public
        isWallet
        atStage(Stages.AuctionSetUp)
    {
        ceiling = _ceiling;
        priceFactor = _priceFactor;
    }

                                            
                                    
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }

                                                                                                                  
                                              
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }

                                                 
                                                                    
    function bid(address receiver)
        public
        payable
        isValidPayload
        timedTransitions
        atStage(Stages.AuctionStarted)
        returns (uint amount)
    {
                                                                                            
        if (receiver == 0)
            receiver = msg.sender;

        require(isInWhitelist(receiver));         
            
        amount = msg.value;
                                                                                           
        uint maxWei = (MAX_TOKENS_SOLD / 10**18) * calcTokenPrice() - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;
                                               
        if (amount > maxWei) {
            amount = maxWei;
                                                                                                                            
            receiver.transfer(msg.value - amount);                     
        }
                                          
        require (amount != 0);
        wallet.transfer(amount);                     
        bids[receiver] += amount;
        totalReceived += amount;
        if (maxWei == amount)
                                                                                                            
            finalizeAuction();
        BidSubmission(receiver, amount);
    }

                                                    
                                                                       
    function claimTokens(address receiver)
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        if (receiver == 0)
            receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**18 / finalPrice;
        bids[receiver] = 0;
        virtuePlayerPoints.transfer(receiver, tokenCount);
    }

                                   
                                   
    function calcStopPrice()
        constant
        public
        returns (uint)
    {
        return totalReceived * 10**18 / MAX_TOKENS_SOLD + 1;
    }

                                    
                                    
    function calcTokenPrice()
        constant
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 8000) + 1;
    }

      
                         
       
    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;
        if (totalReceived == ceiling)
            finalPrice = calcTokenPrice();
        else
            finalPrice = calcStopPrice();
        uint soldTokens = totalReceived * 10**18 / finalPrice;
                                                                          
        virtuePlayerPoints.transfer(wallet, MAX_TOKENS_SOLD - soldTokens);
        endTime = now;
    }
}