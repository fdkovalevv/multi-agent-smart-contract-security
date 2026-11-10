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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract CoinCrowdICO is Ownable {
    using SafeMath for uint256;
    tokenInterface public tokenContract;
    
	uint256 public decimals = 18;
    uint256 public tokenValue;                 
    uint256 public constant centToken = 20;                                
    
    function euroRaised(uint256 _weiTokens) public view returns (uint256) {                                                  
        return _weiTokens.mul(centToken).div(100).div(10**decimals);
    }
    
    uint256 public endTime;                                      
    uint256 public startTime;                                      
    uint256 internal constant weekInSeconds = 604800;                     
    
    uint256 public totalSoldTokensWithBonus;                                               
    uint256 public totalSoldTokensWithoutBonus;                                                             
	function euroRaisedICO() public view returns(uint256 euro) {
        return euroRaised(totalSoldTokensWithoutBonus);
    }
	
    uint256 public remainingTokens;                                                

    mapping(address => address) public ambassadorAddressOf;                                           


    function CoinCrowdICO(address _tokenAddress, uint256 _tokenValue, uint256 _startTime) public {
        tokenContract = tokenInterface(_tokenAddress);
        tokenValue = _tokenValue;
        startICO(_startTime); 
        totalSoldTokensWithBonus = 0;
        totalSoldTokensWithoutBonus = 0;
        remainingTokens = 24500000  * 10 ** decimals;                                          
    }

    address public updater;                                                  
    event UpdateValue(uint256 newValue);

    function updateValue(uint256 newValue) public {
        require(msg.sender == updater || msg.sender == owner);
        tokenValue = newValue;
        UpdateValue(newValue);
    }

    function updateUpdater(address newUpdater) public onlyOwner {
        updater = newUpdater;
    }

    function updateTime(uint256 _newStart, uint256 _newEnd) public onlyOwner {
        if ( _newStart != 0 ) startTime = _newStart;
        if ( _newEnd != 0 ) endTime = _newEnd;
    }
    
    function updateTimeRC(address _rcContract, uint256 _newStart, uint256 _newEnd) public onlyOwner {
        Ambassador(_rcContract).updateTime( _newStart, _newEnd);
    }
    
    function startICO(uint256 _startTime) public onlyOwner {
        if(_startTime == 0 ) {
            startTime = now;
        } else {
            startTime = _startTime;
        }
        endTime = startTime + 12*weekInSeconds;
    }
    
    event Buy(address buyer, uint256 value, address indexed ambassador);

    function buy(address _buyer) public payable returns(uint256) {
        require(now < endTime);                  
        require( remainingTokens > 0 );                                                             
        
        require( tokenContract.balanceOf(this) > remainingTokens);                              
        
        uint256 oneXCC = 10 ** decimals;
        uint256 tokenAmount = msg.value.mul(oneXCC).div(tokenValue);
        
        
        uint256 bonusRate;                                
        address currentAmbassador = address(0);
        if ( ambassadorAddressOf[msg.sender] != address(0) ) {                                          
            currentAmbassador = msg.sender;
            bonusRate = 0;                                                                
            
        } else {                                                  
            require(now > startTime);                                    
            
            if( now > startTime + weekInSeconds*0  ) { bonusRate = 2000; }
            if( now > startTime + weekInSeconds*1  ) { bonusRate = 1833; }
            if( now > startTime + weekInSeconds*2  ) { bonusRate = 1667; }
            if( now > startTime + weekInSeconds*3  ) { bonusRate = 1500; }
            if( now > startTime + weekInSeconds*4  ) { bonusRate = 1333; }
            if( now > startTime + weekInSeconds*5  ) { bonusRate = 1167; }
            if( now > startTime + weekInSeconds*6  ) { bonusRate = 1000; }
            if( now > startTime + weekInSeconds*7  ) { bonusRate = 833; }
            if( now > startTime + weekInSeconds*8  ) { bonusRate = 667; }
            if( now > startTime + weekInSeconds*9  ) { bonusRate = 500; }
            if( now > startTime + weekInSeconds*10 ) { bonusRate = 333; }
            if( now > startTime + weekInSeconds*11 ) { bonusRate = 167; }
            if( now > startTime + weekInSeconds*12 ) { bonusRate = 0; }
        }
        
        if ( remainingTokens < tokenAmount ) {
            uint256 refund = (tokenAmount - remainingTokens).mul(tokenValue).div(oneXCC);
            tokenAmount = remainingTokens;
            owner.transfer(msg.value-refund);
			remainingTokens = 0;                            
             _buyer.transfer(refund);
        } else {
			remainingTokens = remainingTokens.sub(tokenAmount);                                        
            owner.transfer(msg.value);
        }
        
        uint256 tokenAmountWithBonus = tokenAmount.add(tokenAmount.mul( bonusRate ).div(10**4));                  
        
        tokenContract.transfer(_buyer, tokenAmountWithBonus);
        Buy(_buyer, tokenAmountWithBonus, currentAmbassador);
        
        totalSoldTokensWithBonus += tokenAmountWithBonus; 
		totalSoldTokensWithoutBonus += tokenAmount;
		
        return tokenAmount;                                                             
    }

    event NewAmbassador(address ambassador, address contr);
    
    function addMeByRC(address _ambassadorAddr) public {
        require(tx.origin == owner);
        
        ambassadorAddressOf[ msg.sender ]  = _ambassadorAddr;
        
        NewAmbassador(_ambassadorAddr, msg.sender);
    }

    function withdraw(address to, uint256 value) public onlyOwner {
        to.transfer(value);
    }
    
    function updateTokenContract(address _tokenContract) public onlyOwner {
        tokenContract = tokenInterface(_tokenContract);
    }

    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }
    
    function claimPremium(address _buyer, uint256 _amount) public returns(bool) {
        require( ambassadorAddressOf[msg.sender] != address(0) );                                                 
        return tokenContract.transfer(_buyer, _amount);
    }

    function () public payable {
        buy(msg.sender);
    }
}