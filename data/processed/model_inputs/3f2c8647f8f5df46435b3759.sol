contract Crowdsale {
    using SafeMath for uint256;

                           
    ERC20Mintable public token;

                                                                         
    uint256 public startBlock;
    uint256 public endBlock;

                                        
    address public wallet;

                                                
    uint256 public rate;

                                    
    uint256 public weiRaised;

       
                                      
                                              
                                           
                                         
                                              
      
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet) {
        require(_startBlock >= block.number);
        require(_endBlock >= _startBlock);
        require(_rate > 0);
        require(_wallet != 0x0);

        token = createTokenContract();
        startBlock = _startBlock;
        endBlock = _endBlock;
        rate = _rate;
        wallet = _wallet;
    }

                                    
                                                                           
    function createTokenContract() internal returns (ERC20Mintable) {
        return new ERC20Mintable();
    }


                                                  
    function () payable {
        buyTokens(msg.sender);
    }

                                        
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

                                               
        uint256 tokens = weiAmount.mul(rate);

                       
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

                                               
                                                           
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

                                                     
    function validPurchase() internal constant returns (bool) {
        uint256 current = block.number;
        bool withinPeriod = current >= startBlock && current <= endBlock;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

                                                
    function hasEnded() public constant returns (bool) {
        return block.number > endBlock;
    }
}

contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;
    uint256 public cap;

    function CappedCrowdsale(uint256 _cap) {
        require(_cap > 0);
        cap = _cap;
    }

                                                                
                                                      
    function validPurchase() internal constant returns (bool) {
        bool withinCap = weiRaised.add(msg.value) <= cap;
        return super.validPurchase() && withinCap;
    }

                                                     
                                                
    function hasEnded() public constant returns (bool) {
        bool capReached = weiRaised >= cap;
        return super.hasEnded() || capReached;
    }
}

contract WhitelistedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    mapping (address => bool) public whitelist;

    function addToWhitelist(address addr) {
        require(msg.sender != address(this));
        whitelist[addr] = true;
    }

                                                                     
                                                      
    function validPurchase() internal constant returns (bool) {
        return super.validPurchase() || (whitelist[msg.sender] && !hasEnded());
    }

}

contract MDTCrowdsale is CappedCrowdsale, WhitelistedCrowdsale {

    function MDTCrowdsale()
    CappedCrowdsale(50000000000000000000000)
    Crowdsale(block.number, block.number + 100000, 1, msg.sender) {                                                              
        addToWhitelist(msg.sender);
        addToWhitelist(0x0d5bda9db5dd36278c6a40683960ba58cac0149b);
        addToWhitelist(0x1b6ddc637c24305b354d7c337f9126f68aad4886);
    }

}