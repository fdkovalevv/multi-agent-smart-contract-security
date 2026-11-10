contract Ownable {
    
  address public owner;

     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

contract MRDSPrivateSale is Ownable {
    
  using SafeMath for uint;
    
  address multisig;

  uint restrictedPercent;

  address restricted;

  MRDSCoinToken public token = new MRDSCoinToken();

  uint start;
    
  uint period;

  uint rate;

  function MRDSPrivateSale() public {
    multisig = 0x37fE33796c7846419849fE70b086AeEeCAEc8D16;                                   
    restricted = 0x37fE33796c7846419849fE70b086AeEeCAEc8D16;                          
    restrictedPercent = 60;
    rate = 25000000000000000000000;                       
    start = 1520096361;
    period = 17;
  }

  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }

  function createTokens() public saleIsOn payable {
    multisig.transfer(msg.value);
    uint tokens = rate.mul(msg.value).div(1 ether);
    uint bonusTokens = 0;
    if(now < start + (period * 1 days).div(4)) {
      bonusTokens = tokens.div(10).mul(6);
    } else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
      bonusTokens = tokens.div(10).mul(6);
    } else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
      bonusTokens = tokens.div(10).mul(6);
    }
    uint tokensWithBonus = tokens.add(bonusTokens);
    token.transfer(msg.sender, tokensWithBonus);
    uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
    token.transfer(restricted, restrictedTokens);
  }

  function() external payable {
    createTokens();
  }
    
}