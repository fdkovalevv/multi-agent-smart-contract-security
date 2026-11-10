contract Tokensale {
    using SafeMath for uint256;
    
                                                                               
    bool public tokenContractDefined = false;
    
                                                         
    bool public salePhase = true;

                                                        
    uint256 public ethereumSaleRate = 700;                                                   

                                                       
    uint256 public bitcoinSaleRate = 14000;                                                   

                                                       
    Token token;

                                                                       
    AuthenticationManager authenticationManager;

                                              
    mapping(uint256 => bool) public transactionsClaimed;

                                                            
    uint256 public minimunEthereumToInvest = 0;

                                                       
    uint256 public minimunBTCToInvest = 0;

                                                         
    event SaleClosed();

                                                           
    event SaleStarted();

                                             
    event EthereumRateUpdated(uint256 rate, uint256 timestamp);

                                            
    event BitcoinRateUpdated(uint256 rate, uint256 timestamp);

                                                           
    event MinimumEthereumInvestmentUpdated(uint256 _value, uint256 timestamp);

                                                          
    event MinimumBitcoinInvestmentUpdated(uint256 _value, uint256 timestamp);

                                                                                                           
    modifier onlyDuringSale {

        if (!tokenContractDefined || (!salePhase)) throw;
        _;
    }

                                                                           
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) throw;
        _;
    }

                                                                                                   
    function Tokensale(address _authenticationManagerAddress) {        
                
                                                 
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);
    }

                                                                                                                       
                                                            
    function setTokenContractAddress(address _tokenContractAddress) adminOnly {
                                                                        
        if (tokenContractDefined)
            throw;

                                                 
        token = Token(_tokenContractAddress);

        tokenContractDefined = true;
    }

                                                                               
    function processBTCTransaction(bytes txn, uint256 _txHash, address ethereumAddress, bytes20 bitcoinAddress) adminOnly returns (uint256)
    {
                                            
        if(transactionsClaimed[_txHash] != false) 
            throw;

        var (outputValue1, outputAddress1, outputValue2, outputAddress2) = BTC.getFirstTwoOutputs(txn);

        if(BTC.checkValueSent(txn, bitcoinAddress, 1))
        {
            require(outputValue1 >= minimunBTCToInvest);

                                        
            uint256 tokensPurchased = outputValue1 * bitcoinSaleRate * (10**10);  

            token.mintTokens(ethereumAddress, tokensPurchased);

            transactionsClaimed[_txHash] = true;
        }
        else
        {
                                                     
            throw;
        }
    }

    function btcTransactionClaimed(uint256 _txHash) returns(bool) {
        return transactionsClaimed[_txHash];
    }   
    
                                                  
    function () payable {
    
        buyTokens(msg.sender);
    
    }

                                                                                                                                            
    function buyTokens(address beneficiary) onlyDuringSale payable {

        require(beneficiary != 0x0);
        require(validPurchase());
        
        uint256 weiAmount = msg.value;

        uint256 tokensPurchased = weiAmount.mul(ethereumSaleRate);
        
                                                                       
        if (tokensPurchased > 0)
        {
            token.mintTokens(beneficiary, tokensPurchased);
        }
    }

                                                     
    function validPurchase() internal constant returns (bool) {

        bool nonZeroPurchase = ( msg.value != 0 && msg.value >= minimunEthereumToInvest);
        return nonZeroPurchase;
    }

                       
    function setEthereumRate(uint256 _rate) adminOnly {

        ethereumSaleRate = _rate;

                        
        EthereumRateUpdated(ethereumSaleRate, now);
    }

                         
    function setBitcoinRate(uint256 _rate) adminOnly {

        bitcoinSaleRate = _rate;

                        
        BitcoinRateUpdated(bitcoinSaleRate, now);
    }    

                                           
    function setMinimumEthereumToInvest(uint256 _value) adminOnly {

        minimunEthereumToInvest = _value;

                        
        MinimumEthereumInvestmentUpdated(_value, now);
    }    

                                                
    function setMinimumBitcoinToInvest(uint256 _value) adminOnly {

        minimunBTCToInvest = _value;

                        
        MinimumBitcoinInvestmentUpdated(_value, now);
    }

                                                                  
    function close() adminOnly onlyDuringSale {

                         
        salePhase = false;
        SaleClosed();

                                       
        if (!msg.sender.send(this.balance))
            throw;
    }

                            
    function openSale() adminOnly {        
        salePhase = true;
        SaleStarted();
    }
}