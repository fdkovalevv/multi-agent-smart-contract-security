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

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


       
                                                                      
       
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

       
                                                                          
       
    modifier whenPaused {
        require(paused);
        _;
    }

       
                                                                
       
    function pause() onlyOwner whenNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    }

       
                                                                   
       
    function unpause() onlyOwner whenPaused returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}

contract ClaimableCrowdsale is Pausable {
    using SafeMath for uint256;

                                                       
    address beneficiaryAddress;

                                                            
    address public bankAddress;

                     
    HoQuToken public token;

    uint256 public maxTokensAmount;
    uint256 public issuedTokensAmount = 0;
    uint256 public minBuyableAmount;
    uint256 public tokenRate;                           
    
    uint256 endDate;

    bool public isFinished = false;

                                  
    mapping(address => uint256) public tokens;
    mapping(address => bool) public approved;
    mapping(uint32 => address) internal tokenReceivers;
    uint32 internal receiversCount;

       
                                       
      
    event TokenBought(address indexed _buyer, uint256 _tokens, uint256 _amount);
    event TokenAdded(address indexed _receiver, uint256 _tokens, uint256 _equivalentAmount);
    event TokenToppedUp(address indexed _receiver, uint256 _tokens, uint256 _equivalentAmount);
    event TokenSubtracted(address indexed _receiver, uint256 _tokens, uint256 _equivalentAmount);
    event TokenSent(address indexed _receiver, uint256 _tokens);

    modifier inProgress() {
        require (!isFinished);
        require (issuedTokensAmount < maxTokensAmount);
        require (now <= endDate);
        _;
    }
    
       
                                                          
                                                                    
                                                                
                                          
                                                                       
                                                           
                                                   
      
    function ClaimableCrowdsale(
        address _tokenAddress,
        address _bankAddress,
        address _beneficiaryAddress,
        uint256 _tokenRate,
        uint256 _minBuyableAmount,
        uint256 _maxTokensAmount,
        uint256 _endDate
    ) {
        token = HoQuToken(_tokenAddress);

        bankAddress = _bankAddress;
        beneficiaryAddress = _beneficiaryAddress;

        tokenRate = _tokenRate;
        minBuyableAmount = _minBuyableAmount;
        maxTokensAmount = _maxTokensAmount;

        endDate = _endDate;
    }

      
                                             
       
    function setTokenRate(uint256 _tokenRate) onlyOwner {
        require (_tokenRate > 0);
        tokenRate = _tokenRate;
    }

       
                                                                   
       
    function buy() payable inProgress whenNotPaused {
        uint256 payAmount = msg.value;
        uint256 returnAmount = 0;

                                                              
        uint256 tokensAmount = tokenRate.mul(payAmount);
    
        if (issuedTokensAmount + tokensAmount > maxTokensAmount) {
            tokensAmount = maxTokensAmount.sub(issuedTokensAmount);
            payAmount = tokensAmount.div(tokenRate);
            returnAmount = msg.value.sub(payAmount);
        }
    
        issuedTokensAmount = issuedTokensAmount.add(tokensAmount);
        require (issuedTokensAmount <= maxTokensAmount);

        storeTokens(msg.sender, tokensAmount);
        TokenBought(msg.sender, tokensAmount, payAmount);

        beneficiaryAddress.transfer(payAmount);
    
        if (returnAmount > 0) {
            msg.sender.transfer(returnAmount);
        }
    }

       
                                                                                                      
       
    function add(address _receiver, uint256 _equivalentEthAmount) onlyOwner inProgress whenNotPaused {
        uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);
        issuedTokensAmount = issuedTokensAmount.add(tokensAmount);

        storeTokens(_receiver, tokensAmount);
        TokenAdded(_receiver, tokensAmount, _equivalentEthAmount);
    }

       
                                                                                       
       
    function topUp(address _receiver, uint256 _equivalentEthAmount) onlyOwner whenNotPaused {
        uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);
        issuedTokensAmount = issuedTokensAmount.add(tokensAmount);

        storeTokens(_receiver, tokensAmount);
        TokenToppedUp(_receiver, tokensAmount, _equivalentEthAmount);
    }

       
                                                   
       
    function sub(address _receiver, uint256 _equivalentEthAmount) onlyOwner whenNotPaused {
        uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);

        require (tokens[_receiver] >= tokensAmount);

        tokens[_receiver] = tokens[_receiver].sub(tokensAmount);
        issuedTokensAmount = issuedTokensAmount.sub(tokensAmount);

        TokenSubtracted(_receiver, tokensAmount, _equivalentEthAmount);
    }

       
                                                                       
       
    function storeTokens(address _receiver, uint256 _tokensAmount) internal whenNotPaused {
        if (tokens[_receiver] == 0) {
            tokenReceivers[receiversCount] = _receiver;
            receiversCount++;
            approved[_receiver] = false;
        }
        tokens[_receiver] = tokens[_receiver].add(_tokensAmount);
    }

       
                                                                                                          
       
    function claim() whenNotPaused {
        claimFor(msg.sender);
    }

       
                                                         
       
    function claimOne(address _receiver) onlyOwner whenNotPaused {
        claimFor(_receiver);
    }

       
                                                      
       
    function claimAll() onlyOwner whenNotPaused {
        for (uint32 i = 0; i < receiversCount; i++) {
            address receiver = tokenReceivers[i];
            if (approved[receiver] && tokens[receiver] > 0) {
                claimFor(receiver);
            }
        }
    }

       
                                                                        
       
    function claimFor(address _receiver) internal whenNotPaused {
        require(approved[_receiver]);
        require(tokens[_receiver] > 0);

        uint256 tokensToSend = tokens[_receiver];
        tokens[_receiver] = 0;

        token.transferFrom(bankAddress, _receiver, tokensToSend);
        TokenSent(_receiver, tokensToSend);
    }

    function approve(address _receiver) onlyOwner whenNotPaused {
        approved[_receiver] = true;
    }
    
       
                   
       
    function finish() onlyOwner {
        require (issuedTokensAmount >= maxTokensAmount || now > endDate);
        require (!isFinished);
        isFinished = true;
        token.transfer(bankAddress, token.balanceOf(this));
    }

    function getReceiversCount() constant onlyOwner returns (uint32) {
        return receiversCount;
    }

    function getReceiver(uint32 i) constant onlyOwner returns (address) {
        return tokenReceivers[i];
    }
    
       
                                                                   
       
    function() external payable {
        buy();
    }
}

contract ChangeableRateCrowdsale is ClaimableCrowdsale {

    struct RateBoundary {
        uint256 amount;
        uint256 rate;
    }

    mapping (uint => RateBoundary) public rateBoundaries;
    uint public currentBoundary = 0;
    uint public numOfBoundaries = 0;
    uint256 public nextBoundaryAmount;

       
                                                          
                                                                    
                                                                
                                          
                                                                       
                                                           
                                                   
      
    function ChangeableRateCrowdsale(
        address _tokenAddress,
        address _bankAddress,
        address _beneficiaryAddress,
        uint256 _tokenRate,
        uint256 _minBuyableAmount,
        uint256 _maxTokensAmount,
        uint256 _endDate
    ) ClaimableCrowdsale(
        _tokenAddress,
        _bankAddress,
        _beneficiaryAddress,
        _tokenRate,
        _minBuyableAmount,
        _maxTokensAmount,
        _endDate
    ) {
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 13777764 ether,
            rate : 6000
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 27555528 ether,
            rate : 5750
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 41333292 ether,
            rate : 5650
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 55111056 ether,
            rate : 5550
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 68888820 ether,
            rate : 5450
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 82666584 ether,
            rate : 5350
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 96444348 ether,
            rate : 5250
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 110222112 ether,
            rate : 5150
        });
        rateBoundaries[numOfBoundaries++] = RateBoundary({
            amount : 137777640 ether,
            rate : 5000
        });
        nextBoundaryAmount = rateBoundaries[currentBoundary].amount;
    }

       
                                                        
       
    function touchRate() internal {
        if (issuedTokensAmount >= nextBoundaryAmount) {
            currentBoundary++;
            if (currentBoundary >= numOfBoundaries) {
                nextBoundaryAmount = maxTokensAmount;
            }
            else {
                nextBoundaryAmount = rateBoundaries[currentBoundary].amount;
                tokenRate = rateBoundaries[currentBoundary].rate;
            }
        }
    }

       
                                                                                 
       
    function storeTokens(address _receiver, uint256 _tokensAmount) internal whenNotPaused {
        ClaimableCrowdsale.storeTokens(_receiver, _tokensAmount);
        touchRate();
    }
}