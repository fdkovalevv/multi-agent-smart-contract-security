contract Crowdsale {
    using SafeMath for uint256;

                           
    MintableToken public token;

    uint256 public hardCap = 100000000 * (10**18);

                                        
    address public wallet = 0xD0b6c1F479eACcce7A77D5Aa3b6c9fc2213EecCb;

                                                
    uint256 public rate = 40000;

                                    
    uint256 public weiRaised;

                        
    uint public bonus20end = 1519862400;
                        
    uint public bonus15end = 1522540800;
                      
    uint public bonus10end = 1525132800;


       
                                       
                                               
                                            
                                          
                                               
       
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Value(uint256 indexed value);

    function Crowdsale() public {
        token = createTokenContract();
    }

                                    
                                                                           
    function createTokenContract() internal returns (MintableToken) {
        return new MintableToken();
    }

                                                  
    function () external payable {
        buyTokens(msg.sender);
    }

                                        
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());
        require(!hasEnded());

        uint256 weiAmount = msg.value;

                                               
        uint256 tokens = weiAmount.mul(rate).mul(getCurrentBonus()).div(100);

                       
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        forwardFunds();
    }

                                               
                                                           
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

                                                     
    function validPurchase() internal view returns (bool) {
        bool nonZeroPurchase = msg.value != 0;
        return nonZeroPurchase;
    }

                                                
    function hasEnded() public view returns (bool) {
        return token.totalSupply() >= hardCap;
    }

    function getCurrentBonus() public view returns (uint) {
        if (now < bonus20end) return 120;
        if (now < bonus15end) return 115;
        if (now < bonus10end) return 110;
        return 100;
    }
}