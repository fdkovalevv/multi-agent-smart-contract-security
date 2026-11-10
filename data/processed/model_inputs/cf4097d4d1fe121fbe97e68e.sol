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
    require(newOwner != address(0));
    owner = newOwner;
  }

}

contract Claimable is Ownable {
  address public pendingOwner;

     
                                                                               
     
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

     
                                                                   
                                                          
     
  function transferOwnership(address newOwner) onlyOwner {
    pendingOwner = newOwner;
  }

     
                                                                   
     
  function claimOwnership() onlyPendingOwner {
    owner = pendingOwner;
    pendingOwner = 0x0;
  }
}

contract DecisionTokenSale is Claimable {
  using SafeMath for uint256;

                                                              
                                                                       
  uint256 public startTime;

                                                            
                                                                         
  uint256 public endTime;

                                                                     
  uint256 public constant presaleTokenRate = 3750;

                                                    
  uint256 public constant earlyBirdTokenRate = 3500;

                                                    
  uint256 public constant secondStageTokenRate = 3250;

                                                     
  uint256 public constant thirdStageTokenRate = 3000;

                                                                                  
  uint256 public constant tokenCap =  10**9 * 10**18;

                                                                                
  uint256 public constant tokenReserve = 4 * (10**8) * 10**18;

                                                         
  DecisionToken public token;

                                         
  address public wallet;

                                                                            
                                                          
  mapping (address => bool) whiteListedForPresale;

                                            
  event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

                                                
  event LogUserAddedToWhiteList(address indexed user);

                                                   
  event LogUserUserRemovedFromWhiteList(address indexed user);


                       
                                                                  
                                                                               
  function DecisionTokenSale(uint256 _startTime, address _wallet) {
    require(_startTime >= now);
    require(_wallet != 0x0);
    startTime = _startTime;
    endTime = startTime.add(14 days);
    wallet = _wallet;

                                        
    token = createTokenContract();

                                                                 
    token.mint(owner, tokenReserve);
  }

                                                    
                                                    
  function createTokenContract() internal returns (DecisionToken) {
    return new DecisionToken();
  }

                               
                                                          
  function buyTokens() payable {
    require(msg.sender != 0x0);
    require(msg.value != 0);
    require(whiteListedForPresale[msg.sender] || now >= startTime);
    require(!hasEnded());

                                           
    uint256 tokens = calculateTokenAmount(msg.value);

    if (token.totalSupply().add(tokens) > tokenCap) {
      revert();
    }

                                            
    token.mint(msg.sender, tokens);

                                                 
    TokenPurchase(msg.sender, msg.value, tokens);

                                             
    wallet.transfer(msg.value);
  }

                                                             
  function () payable {
    buyTokens();
  }

                                               
                                                                                   
                                                         
                                      
                                      
                                      
                                      
    
                                                                                
                                                                                 
                                                           
    
                                                                        
                                                    
  function calculateTokenAmount(uint256 _weiAmount) internal constant returns (uint256) {
    if (now >= startTime + 8 days) {
      return _weiAmount.mul(thirdStageTokenRate);
    }
    if (now >= startTime + 1 days) {
      return _weiAmount.mul(secondStageTokenRate);
    }
    if (now >= startTime) {
      return _weiAmount.mul(earlyBirdTokenRate);
    }
    return _weiAmount.mul(presaleTokenRate);
  }

                                              
                                                                                  
                       
                                                                                       
                                        
                                              
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }

                                               
                                                                
                                                                           
                                                   
  function whiteListAddress(address _buyer) onlyOwner {
    require(_buyer != 0x0);
    whiteListedForPresale[_buyer] = true;
    LogUserAddedToWhiteList(_buyer);
  }

                                                       
                                                                                 
                                                                           
                                                      
  function addWhiteListedAddressesInBatch(address[] _buyers) onlyOwner {
    require(_buyers.length < 1000);
    for (uint i = 0; i < _buyers.length; i++) {
      whiteListAddress(_buyers[i]);
    }
  }

                                              
                                                                                 
                                                                   
  function removeWhiteListedAddress(address _buyer) onlyOwner {
    whiteListedForPresale[_buyer] = false;
  }

                                  
                                                          
                                                                             
  function destroy() onlyOwner {
    token.finishMinting();
    token.transferOwnership(msg.sender);
    selfdestruct(owner);
  }
}