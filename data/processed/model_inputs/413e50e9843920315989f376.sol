contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }


     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

     
                                                                                
     
  modifier whenPaused() {
    require(paused);
    _;
  }

     
                                                              
     
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

     
                                                                 
     
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract DropletCrowdSale is Pausable {
    using SafeMath for uint256;

    address beneficiaryAddress;

                     
    DropletToken public token;

    uint256 public maxTokensAmount;
    uint256 public issuedTokensAmount = 0;
    uint256 public tokenRate;                   

    uint256 public endDate;

    bool public isFinished = false;
    bool public isUnlocked = false;

                                  
    mapping(address => uint256) public tokens;
    mapping(uint32 => address) public tokenReceivers;
    uint32 public receiversCount = 0;

       
                                       
      
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

    function DropletCrowdSale(
        address _tokenAddress,
        address _beneficiaryAddress,
        uint256 _tokenRate,
        uint256 _maxTokensAmount,
        uint256 _endDate
    ) public {
        token = DropletToken(_tokenAddress);
        beneficiaryAddress = _beneficiaryAddress;

        tokenRate = _tokenRate;
        maxTokensAmount = _maxTokensAmount;

        endDate = _endDate;
    }

      
                                                
       
    function setTokenRate(uint256 _tokenRate) public onlyOwner {
        require (_tokenRate > 0);
        tokenRate = _tokenRate;
    }

      
                                                
       
    function setEndDate(uint256 _endDate) public onlyOwner {
        endDate = _endDate;
    }

       
                                                                       
       
    function buy() public payable inProgress whenNotPaused {
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

       
                                                                                       
       
    function add(address _receiver, uint256 _equivalentEthAmount) public onlyOwner inProgress whenNotPaused {
        uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);
        issuedTokensAmount = issuedTokensAmount.add(tokensAmount);

        storeTokens(_receiver, tokensAmount);
        TokenAdded(_receiver, tokensAmount, _equivalentEthAmount);
    }

       
                                                                                  
       
    function topUp(address _receiver, uint256 _equivalentEthAmount) public onlyOwner whenNotPaused {
        uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);
        issuedTokensAmount = issuedTokensAmount.add(tokensAmount);

        storeTokens(_receiver, tokensAmount);
        TokenToppedUp(_receiver, tokensAmount, _equivalentEthAmount);
    }

       
                                                     
       
    function sub(address _receiver, uint256 _equivalentEthAmount) public onlyOwner whenNotPaused {
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
        }
        tokens[_receiver] = tokens[_receiver].add(_tokensAmount);
    }

       
                                                                                                       
       
    function claim() public whenNotPaused {
        claimFor(msg.sender);
    }

       
                                                   
       
    function claimOne(address _receiver) public onlyOwner whenNotPaused {
        claimFor(_receiver);
    }

       
                                                
       
    function claimAll() public onlyOwner whenNotPaused {
        for (uint32 i = 0; i < receiversCount; i++) {
            address receiver = tokenReceivers[i];
            if (isUnlocked && tokens[receiver] > 0) {
                claimFor(receiver);
            }
        }
    }

       
                                                               
       
    function claimFor(address _receiver) internal whenNotPaused {
        require(isUnlocked);
        require(tokens[_receiver] > 0);

        uint256 tokensToSend = tokens[_receiver];
        tokens[_receiver] = 0;

        require(token.transferFrom(owner, _receiver, tokensToSend));
        TokenSent(_receiver, tokensToSend);
    }

    function unLockTokens() public onlyOwner whenNotPaused {
        isUnlocked = true;
    }

    function lockTokens() public onlyOwner whenNotPaused {
        isUnlocked = false;
    }

       
                   
       
    function finish() public onlyOwner {
        require (!isFinished);
        isFinished = true;
    }

    function getReceiversCount() public constant onlyOwner returns (uint32) {
        return receiversCount;
    }

    function getReceiver(uint32 i) public constant onlyOwner returns (address) {
        return tokenReceivers[i];
    }

       
                                                                     
       
    function() external payable {
        buy();
    }
}