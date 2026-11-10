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

contract TokenDestructible is Ownable {

  function TokenDestructible() public payable { }

     
                                                   
                                                                              
          
                                                                                 
                                    
     
  function destroy(address[] tokens) onlyOwner public {

                               
    for(uint256 i = 0; i < tokens.length; i++) {
      ERC20Basic token = ERC20Basic(tokens[i]);
      uint256 balance = token.balanceOf(this);
      token.transfer(owner, balance);
    }

                                                   
    selfdestruct(owner);
  }
}

contract XmasCoinCrowdsale is Ownable, Pausable, TokenDestructible {
  using SafeMath for uint256;

                         
  XmasCoin public token;

                                  
                             
                                  
  uint256 public tokenRaised;

    uint256 public constant cap = 7500000 * (10 ** uint256(18));

    bool public crowdsaleClosed = false;

     
                                     
                                             
                                          
                                        
                                             
     
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  uint256 constant public startTime = 1512305200;
  uint256 constant public endTime = 1515369599;
  address constant public wallet = 0xE0D9f548E5A62C7a06F0690edE9621BF17620683;

  function XmasCoinCrowdsale() public {
    token = new XmasCoin();
  }



                                           
                                                                                 
  function getRate() public constant returns (uint256) {            
    if      (block.timestamp <= 1513382399)          return 45000;             
    else if (block.timestamp <= 1514246399)          return 39000;
    else if (block.timestamp <= 1514764799)          return 36000;
    return 30000;
  }


                                                
  function () external payable {
    buyTokens(msg.sender);
  }

                                      
  function buyTokens(address beneficiary) whenNotPaused public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

                                           
    uint256 tokens = weiAmount.mul(getRate()).div(10);
   

                   
                                           
    tokenRaised = tokenRaised.add(tokens);

     if(!((cap.sub(tokenRaised))>=0)) {
      revert();
    }

    wallet.transfer(msg.value);
    token.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
  }

                                                   
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

       
                                                                    
   
    function finalize() onlyOwner public {
        require(!crowdsaleClosed);

        if(now < endTime) {
            require(tokenRaised == cap);
        }
        require(wallet.send(this.balance));
        uint remains = cap.sub(tokenRaised);
        if (remains>0) {
          token.burn(remains);
        }

        crowdsaleClosed = true;
    }


}