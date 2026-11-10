contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function Ownable() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Pausable is Ownable {
    bool public paused = false;

    event Pause();
    event Unpause();

    modifier whenNotPaused() { require(!paused); _; }
    modifier whenPaused() { require(paused); _; }

    function pause() onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }
    
    function unpause() onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}

contract Crowdsale is Pausable {
    using SafeMath for uint;

    Token public token;
    address public beneficiary = 0xF59125FCB92bBB364e7F3c106E9BAEb8b4bB69B0;        

    uint public collectedWei;
    uint public tokensSold;

    uint public tokensForSale = 20000000 * 1 ether;                                                          
    uint public priceTokenWei = 1 ether / 20;                                                                   

    bool public crowdsaleFinished = false;

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Withdraw();

    function Crowdsale() {
        token = new Token();
    }

    function() payable {
        purchase();
    }

    function setTokenPrice(uint _value) onlyOwner whenPaused {
        require(!crowdsaleFinished);
        priceTokenWei = 1 ether / _value;
    }
    
    function purchase() whenNotPaused payable {
        require(!crowdsaleFinished);
        require(tokensSold < tokensForSale);
        require(msg.value >= 1 ether && msg.value <= 10000 * 1 ether);

        uint sum = msg.value;
        uint amount = sum.div(priceTokenWei).mul(1 ether);
        uint retSum = 0;
        
        if(tokensSold.add(amount) > tokensForSale) {
            uint retAmount = tokensSold.add(amount).sub(tokensForSale);
            retSum = retAmount.mul(priceTokenWei).div(1 ether);

            amount = amount.sub(retAmount);
            sum = sum.sub(retSum);
        }

        tokensSold = tokensSold.add(amount);
        collectedWei = collectedWei.add(sum);

        beneficiary.transfer(sum);
        token.mint(msg.sender, amount);

        if(retSum > 0) {
            msg.sender.transfer(retSum);
        }

        NewContribution(msg.sender, amount, sum);
    }

    function withdraw() onlyOwner {
        require(!crowdsaleFinished);
        
        if(tokensForSale.sub(tokensSold) > 0) {
            token.mint(beneficiary, tokensForSale.sub(tokensSold));
        }

        token.finishMinting();
        token.transferOwnership(beneficiary);

        crowdsaleFinished = true;

        Withdraw();
    }

    function balanceOf(address _owner) constant returns(uint256 balance) {
        return token.balanceOf(_owner);
    }
}