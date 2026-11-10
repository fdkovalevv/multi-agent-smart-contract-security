contract Ownable {
  address public owner;


     
                                                                                         
             
     
  function Ownable() {
    owner = msg.sender;
  }


     
                                                               
     
                                                                   

  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert();
    }
    _;
  }


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Crowdsale {
  using SafeMath for uint256;

                         
  MintableToken public token;

                                                                       
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

                                  
                                                                         
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
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

contract NatCoinCrowdsale is Crowdsale, Ownable {

  uint256 public icoSupply;
  uint256 public reserveSupply;
  uint256 public paymentSupply;
  uint256 public coreSupply;
  uint256 public reveralSupply;

  uint256 public usedIcoSupply;
  uint256 public usedReserveSupply;
  uint256 public usedPaymentSupply;
  uint256 public usedCoreSupply;
  uint256 public usedReveralSupply;

  function getIcoSupply() public returns(uint256) { return icoSupply; }
  function getReserveSupply() public returns(uint256) { return reserveSupply; }
  function getPaymentSupply() public returns(uint256) { return paymentSupply; }
  function getCoreSupply() public returns(uint256) { return coreSupply; }
  function getReveralSupply() public returns(uint256) { return reveralSupply; }

  function getUsedReserveSupply() public returns(uint256) { return usedReserveSupply; }
  function getUsedPaymentSupply() public returns(uint256) { return usedPaymentSupply; }
  function getUsedCoreSupply() public returns(uint256) { return usedCoreSupply; }
  function getUsedReveralSupply() public returns(uint256) { return usedReveralSupply; }

  NatCoin natcoinTokenContract;

  function NatCoinCrowdsale(uint256 _startBlock, uint256 _endBlock, uint256 _rate, address _wallet) Crowdsale(_startBlock, _endBlock, _rate, _wallet) {
    icoSupply =      5000000 * 10**17;
    reserveSupply =  8000000 * 10**17;
    paymentSupply = 11000000 * 10**17;
    coreSupply =    10500000 * 10**17;
    reveralSupply =   500000 * 10**17;
  }

                                  
                                                                              
  function createTokenContract() internal returns (MintableToken) {
    return new NatCoin();
  }

  function claimReservedTokens(address _to, uint256 _amount) payable onlyOwner {
    if (_amount > reserveSupply - usedReserveSupply) revert();
    token.mint(_to, _amount);
    reserveSupply += _amount;
  }

  function claimPaymentTokens(address _to, uint256 _amount) payable onlyOwner {
    if (_amount > paymentSupply - usedPaymentSupply) revert();
    token.mint(_to, _amount);
    paymentSupply += _amount;
  }

  function claimCoreTokens(address _to, uint256 _amount) payable onlyOwner {
    if (_amount > coreSupply - usedCoreSupply) revert();
    natcoinTokenContract.mint(_to, _amount);
    coreSupply += _amount;
  }

  function claimReveralTokens(address _to, uint256 _amount) payable onlyOwner {
    if (_amount > reveralSupply - usedReveralSupply) revert();
    natcoinTokenContract.mint(_to, _amount);
    reveralSupply += _amount;
  }

}