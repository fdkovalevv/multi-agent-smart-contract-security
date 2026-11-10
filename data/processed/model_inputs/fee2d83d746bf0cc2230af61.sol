contract Ownable {
    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract Crowdsale is Ownable {
    using SafeMath for uint256;
                           
    ObizcoinCrowdsaleToken public token;
                                        
    address public wallet;
                                    
    uint256 public weiRaised;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint mytime);

    function Crowdsale() {
        token = createTokenContract();
        wallet = msg.sender;
    }

    function setNewWallet(address newWallet) onlyOwner {
        require(newWallet != 0x0);
        wallet = newWallet;
    }

    function createTokenContract() internal returns (ObizcoinCrowdsaleToken) {
        return new ObizcoinCrowdsaleToken();
    }
                                                  
    function() payable {
        buyTokens(msg.sender);
    }

    function profitSharing() payable public {
        uint256 weiAmount = msg.value;
        uint256 ballanceOfHolder;
        for (uint i = 0; i < holders.length; i++)
        {
            ballanceOfHolder = token.balanceOf(holders[i]);
            if (ballanceOfHolder > 0) {
                holders[i].transfer(ballanceOfHolder.mul(weiAmount).div(token.totalSupply()));
            }
        }
    }

    function destroyMyToken(uint256 amount) onlyOwner {
        token.destroy(amount.mul(1000000000000000000), msg.sender);
    }

        uint time0 = 1512970200;                                           
                                    
    uint time1 = time0 + 15 days;

    uint time2 = time1 + 44 days + 5 hours + 5 minutes;                                  

    uint time3 = time0 + 49 days;

    uint time4 = time3 + 1 weeks;

    uint time5 = time3 + 2 weeks;

    uint time6 = time3 + 3 weeks;

    uint time7 = time2 + 34 days;

                                        
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());
        require(!hasEnded());
        uint256 weiAmount = msg.value;
        uint256 tokens;
                                               

        if (block.timestamp >= time0 && block.timestamp < time1) tokens = weiAmount.mul(11000);
        else if (block.timestamp >= time1 && block.timestamp < time2) tokens = weiAmount.mul(10000);
        else if (block.timestamp >= time3 && block.timestamp < time4) tokens = weiAmount.mul(9000);
        else if (block.timestamp >= time4 && block.timestamp < time5) tokens = weiAmount.mul(8000);
        else if (block.timestamp >= time5 && block.timestamp < time6) tokens = weiAmount.mul(7000);
        else if (block.timestamp >= time6 && block.timestamp < time7) tokens = weiAmount.mul(6000);

                       
        weiRaised = weiRaised.add(weiAmount);
        token.mint(beneficiary, tokens);
        addNewHolder(beneficiary);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, block.timestamp);
        forwardFunds();
    }

    function mintTokens(address beneficiary, uint256 tokens) internal {
        uint256 weiAmount;
        if (block.timestamp >= time0 && block.timestamp < time1) weiAmount = tokens.div(11000);
        else if (block.timestamp >= time1 && block.timestamp < time2) weiAmount = tokens.div(10000);
        else if (block.timestamp >= time3 && block.timestamp < time4) weiAmount = tokens.div(9000);
        else if (block.timestamp >= time4 && block.timestamp < time5) weiAmount = tokens.div(8000);
        else if (block.timestamp >= time5 && block.timestamp < time6) weiAmount = tokens.div(7000);
        else if (block.timestamp >= time6 && block.timestamp < time7) weiAmount = tokens.div(6000);

        weiRaised = weiRaised.add(weiAmount);
        token.mint(beneficiary, tokens);
        addNewHolder(beneficiary);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, block.timestamp);
    }

                                               
                                                           
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
                                                     
    function validPurchase() internal constant returns (bool) {
        return msg.value != 0;
    }
                                                
    function hasEnded() public constant returns (bool) {
        return block.timestamp < time0 || (block.timestamp > time2 && block.timestamp < time3) || block.timestamp > time7;
    }

    mapping (address => bool) isHolder;

    address[] public holders;

    function addNewHolder(address newHolder) internal {
        if (!isHolder[newHolder]) {
            holders.push(newHolder);
            isHolder[newHolder] = true;
        }
    }
}

contract ObizcoinCrowdsale is Crowdsale {

    uint256 public investors;

    ProfitSharingObizcoin public profitSharingContract;

    function ObizcoinCrowdsale()
    Crowdsale()
    {
        investors = 0;
        profitSharingContract = new ProfitSharingObizcoin();
    }


    function buyObizcoinTokens(address _sender) payable {
        investors++;
        buyTokens(_sender);
    }

    function mintObizcoinTokens(address beneficiary, uint256 tokens) onlyOwner {
        investors++;
        mintTokens(beneficiary, tokens.mul(1000000000000000000));
    }

    function() payable {
        buyObizcoinTokens(msg.sender);
    }

}