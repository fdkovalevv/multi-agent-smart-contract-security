contract Ownable {
  address public owner;
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     
                                                                                         
             
     
  function Ownable() internal {
    owner = msg.sender;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract TokenSale is Ownable {
    using SafeMath for uint256;
    tokenInterface public tokenContract;
    rateInterface public rateContract;
    
    address public wallet;
    address public advisor;
    uint256 public advisorFee;            
    
	uint256 public constant decimals = 18;
    
    uint256 public endTime;                                      
    uint256 public startTime;                                      

    mapping(address => bool) public rc;


    function TokenSale(address _tokenAddress, address _rateAddress, uint256 _startTime, uint256 _endTime) public {
        tokenContract = tokenInterface(_tokenAddress);
        rateContract = rateInterface(_rateAddress);
        setTime(_startTime, _endTime); 
        wallet = msg.sender;
        advisor = msg.sender;
        advisorFee = 0 * 10**3;
    }
    
    function tokenValueInEther(uint256 _oneTokenInFiatWei) public view returns(uint256 tknValue) {
        uint256 oneEtherInUsd = rateContract.readRate("usd");
        tknValue = _oneTokenInFiatWei.mul(10 ** uint256(decimals)).div(oneEtherInUsd);
        return tknValue;
    } 
    
    modifier isBuyable() {
        require( now > startTime );                    
        require( now < endTime );                  
        require( msg.value > 0 );
		
		uint256 remainingTokens = tokenContract.balanceOf(this);
        require( remainingTokens > 0 );                                            
        _;
    }
    
    event Buy(address buyer, uint256 value, address indexed ambassador);
    
    modifier onlyRC() {
        require( rc[msg.sender] );                                       
        _;
    }
    
    function buyFromRC(address _buyer, uint256 _rcTokenValue, uint256 _remainingTokens) onlyRC isBuyable public payable returns(uint256) {
        uint256 oneToken = 10 ** uint256(decimals);
        uint256 tokenValue = tokenValueInEther(_rcTokenValue);
        uint256 tokenAmount = msg.value.mul(oneToken).div(tokenValue);
        address _ambassador = msg.sender;
        
        
        uint256 remainingTokens = tokenContract.balanceOf(this);
        if ( _remainingTokens < remainingTokens ) {
            remainingTokens = _remainingTokens;
        }
        
        if ( remainingTokens < tokenAmount ) {
            uint256 refund = (tokenAmount - remainingTokens).mul(tokenValue).div(oneToken);
            tokenAmount = remainingTokens;
            forward(msg.value-refund);
			remainingTokens = 0;                            
             _buyer.transfer(refund);
        } else {
			remainingTokens = remainingTokens.sub(tokenAmount);                                        
            forward(msg.value);
        }
        
        tokenContract.transfer(_buyer, tokenAmount);
        emit Buy(_buyer, tokenAmount, _ambassador);
		
        return tokenAmount; 
    }
    
    function forward(uint256 _amount) internal {
        uint256 advisorAmount = _amount.mul(advisorFee).div(10**3);
        uint256 walletAmount = _amount - advisorAmount;
        advisor.transfer(advisorAmount);
        wallet.transfer(walletAmount);
    }

    event NewRC(address contr);
    
    function addMeByRC() public {
        require(tx.origin == owner);
        
        rc[ msg.sender ]  = true;
        
        emit NewRC(msg.sender);
    }
    
    function setTime(uint256 _newStart, uint256 _newEnd) public onlyOwner {
        if ( _newStart != 0 ) startTime = _newStart;
        if ( _newEnd != 0 ) endTime = _newEnd;
    }

    function withdraw(address to, uint256 value) public onlyOwner {
        to.transfer(value);
    }
    
    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }
    
    function setTokenContract(address _tokenContract) public onlyOwner {
        tokenContract = tokenInterface(_tokenContract);
    }

    function setWalletAddress(address _wallet) public onlyOwner {
        wallet = _wallet;
    }
    
    function setAdvisorAddress(address _advisor) public onlyOwner {
            advisor = _advisor;
    }
    
    function setAdvisorFee(uint256 _advisorFee) public onlyOwner {
            advisorFee = _advisorFee;
    }
    
    function setRateContract(address _rateAddress) public onlyOwner {
        rateContract = rateInterface(_rateAddress);
    }
	
	function claim(address _buyer, uint256 _amount) onlyRC public returns(bool) {
        return tokenContract.transfer(_buyer, _amount);
    }

    function () public payable {
        revert();
    }
}