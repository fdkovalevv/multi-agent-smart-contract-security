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

     
                                                              
     
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

     
                                                                 
     
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
  
}

contract StagedCrowdsale is Pausable {

  using SafeMath for uint;

  struct Milestone {
    uint period;
    uint bonus;
  }

  uint public start;

  uint public totalPeriod;

  uint public invested;

  uint public hardCap;
 
  Milestone[] public milestones;

  function milestonesCount() constant returns(uint) {
    return milestones.length;
  }

  function setStart(uint newStart) onlyOwner {
    start = newStart;
  }

  function setHardcap(uint newHardcap) onlyOwner {
    hardCap = newHardcap;
  }

  function addMilestone(uint period, uint bonus) onlyOwner {
    require(period > 0);
    milestones.push(Milestone(period, bonus));
    totalPeriod = totalPeriod.add(period);
  }

  function removeMilestones(uint8 number) onlyOwner {
    require(number < milestones.length);
    Milestone storage milestone = milestones[number];
    totalPeriod = totalPeriod.sub(milestone.period);

    delete milestones[number];

    for (uint i = number; i < milestones.length - 1; i++) {
      milestones[i] = milestones[i+1];
    }

    milestones.length--;
  }

  function changeMilestone(uint8 number, uint period, uint bonus) onlyOwner {
    require(number < milestones.length);
    Milestone storage milestone = milestones[number];

    totalPeriod = totalPeriod.sub(milestone.period);    

    milestone.period = period;
    milestone.bonus = bonus;

    totalPeriod = totalPeriod.add(period);    
  }

  function insertMilestone(uint8 numberAfter, uint period, uint bonus) onlyOwner {
    require(numberAfter < milestones.length);

    totalPeriod = totalPeriod.add(period);

    milestones.length++;

    for (uint i = milestones.length - 2; i > numberAfter; i--) {
      milestones[i + 1] = milestones[i];
    }

    milestones[numberAfter + 1] = Milestone(period, bonus);
  }

  function clearMilestones() onlyOwner {
    require(milestones.length > 0);
    for (uint i = 0; i < milestones.length; i++) {
      delete milestones[i];
    }
    milestones.length -= milestones.length;
    totalPeriod = 0;
  }

  modifier saleIsOn() {
    require(milestones.length > 0 && now >= start && now < lastSaleDate());
    _;
  }
  
  modifier isUnderHardCap() {
    require(invested <= hardCap);
    _;
  }
  
  function lastSaleDate() constant returns(uint) {
    require(milestones.length > 0);
    return start + totalPeriod * 1 days;
  }

  function currentMilestone() saleIsOn constant returns(uint) {
    uint previousDate = start;
    for(uint i=0; i < milestones.length; i++) {
      if(now >= previousDate && now < previousDate + milestones[i].period * 1 days) {
        return i;
      }
      previousDate = previousDate.add(milestones[i].period * 1 days);
    }
    revert();
  }

}

contract CommonSale is StagedCrowdsale {

  address public multisigWallet;
  
  address public foundersTokensWallet;
  
  address public bountyTokensWallet;

  uint public foundersTokensPercent;
  
  uint public bountyTokensPercent;
 
  uint public price;

  uint public percentRate = 100;

  uint public softcap;

  bool public refundOn = false;

  bool public isSoftcapOn = false;

  mapping (address => uint) balances;

  CommonSale public nextSale;
  
  MintableToken public token;

  function setSoftcap(uint newSoftcap) onlyOwner {
    isSoftcapOn = true;
    softcap = newSoftcap;
  }

  function setToken(address newToken) onlyOwner {
    token = MintableToken(newToken);
  }

  function setNextSale(address newNextSale) onlyOwner {
    nextSale = CommonSale(newNextSale);
  }

  function setPrice(uint newPrice) onlyOwner {
    price = newPrice;
  }

  function setPercentRate(uint newPercentRate) onlyOwner {
    percentRate = newPercentRate;
  }

  function setFoundersTokensPercent(uint newFoundersTokensPercent) onlyOwner {
    foundersTokensPercent = newFoundersTokensPercent;
  }
  
  function setBountyTokensPercent(uint newBountyTokensPercent) onlyOwner {
    bountyTokensPercent = newBountyTokensPercent;
  }
  
  function setMultisigWallet(address newMultisigWallet) onlyOwner {
    multisigWallet = newMultisigWallet;
  }

  function setFoundersTokensWallet(address newFoundersTokensWallet) onlyOwner {
    foundersTokensWallet = newFoundersTokensWallet;
  }

  function setBountyTokensWallet(address newBountyTokensWallet) onlyOwner {
    bountyTokensWallet = newBountyTokensWallet;
  }

  function createTokens() whenNotPaused isUnderHardCap saleIsOn payable {
    require(msg.value >= 100000000000000000);
    uint milestoneIndex = currentMilestone();
    Milestone storage milestone = milestones[milestoneIndex];
    if(!isSoftcapOn) {
      multisigWallet.transfer(msg.value);
    }
    invested = invested.add(msg.value);
    uint tokens = msg.value.mul(1 ether).div(price);
    uint bonusTokens = tokens.mul(milestone.bonus).div(percentRate);
    uint tokensWithBonus = tokens.add(bonusTokens);
    token.mint(this, tokensWithBonus);
    token.transfer(msg.sender, tokensWithBonus);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
  }

  function refund() whenNotPaused {
    require(now > start && refundOn && balances[msg.sender] > 0);
    msg.sender.transfer(balances[msg.sender]);
  } 

  function finishMinting() public whenNotPaused onlyOwner {
    if(isSoftcapOn && invested < softcap) {
      refundOn = true;
      token.finishMinting();
    } else {
      if(isSoftcapOn) {
        multisigWallet.transfer(invested);
      }
      uint issuedTokenSupply = token.totalSupply();
      uint summaryTokensPercent = bountyTokensPercent + foundersTokensPercent;
      uint summaryFoundersTokens = issuedTokenSupply.mul(summaryTokensPercent).div(percentRate - summaryTokensPercent);
      uint totalSupply = summaryFoundersTokens + issuedTokenSupply;
      uint foundersTokens = totalSupply.mul(foundersTokensPercent).div(percentRate);
      uint bountyTokens = totalSupply.mul(bountyTokensPercent).div(percentRate);
      token.mint(this, foundersTokens);
      token.transfer(foundersTokensWallet, foundersTokens);
      token.mint(this, bountyTokens);
      token.transfer(bountyTokensWallet, bountyTokens);
      if(nextSale == address(0)) {
        token.finishMinting();
      } else {
        token.setSaleAgent(nextSale);
      }
    }
  }

  function() external payable {
    createTokens();
  }

  function retrieveTokens(address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(multisigWallet, token.balanceOf(this));
  }

}