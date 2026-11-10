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

contract NextSaleAgentFeature is Ownable {

  address public nextSaleAgent;

  function setNextSaleAgent(address newNextSaleAgent) public onlyOwner {
    nextSaleAgent = newNextSaleAgent;
  }

}

contract PercentRateProvider is Ownable {

  uint public percentRate = 100;

  function setPercentRate(uint newPercentRate) public onlyOwner {
    percentRate = newPercentRate;
  }

}

contract CommonSale is PercentRateProvider {

  using SafeMath for uint;

  address public wallet;

  address public directMintAgent;

  uint public price;

  uint public start;

  uint public minInvestedLimit;

  REPUToken public token;

  DevWallet public devWallet;

  bool public devWalletLocked;

  uint public hardcap;

  uint public invested;

  modifier isUnderHardcap() {
    require(invested < hardcap);
    _;
  }

  function setHardcap(uint newHardcap) public onlyOwner {
    hardcap = newHardcap;
  }

  modifier onlyDirectMintAgentOrOwner() {
    require(directMintAgent == msg.sender || owner == msg.sender);
    _;
  }

  modifier minInvestLimited(uint value) {
    require(value >= minInvestedLimit);
    _;
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }

  function setMinInvestedLimit(uint newMinInvestedLimit) public onlyOwner {
    minInvestedLimit = newMinInvestedLimit;
  }

  function setDirectMintAgent(address newDirectMintAgent) public onlyOwner {
    directMintAgent = newDirectMintAgent;
  }

  function setWallet(address newWallet) public onlyOwner {
    wallet = newWallet;
  }

  function setPrice(uint newPrice) public onlyOwner {
    price = newPrice;
  }

  function setToken(address newToken) public onlyOwner {
    token = REPUToken(newToken);
  }

  function setDevWallet(address newDevWallet) public onlyOwner {
    require(!devWalletLocked);
    devWallet = DevWallet(newDevWallet);
    devWalletLocked = true;
  }

  function calculateTokens(uint _invested) internal returns(uint);

  function mintTokensExternal(address to, uint tokens) public onlyDirectMintAgentOrOwner {
    mintTokens(to, tokens);
  }

  function mintTokens(address to, uint tokens) internal {
    token.mint(this, tokens);
    token.transfer(to, tokens);
  }

  function endSaleDate() public view returns(uint);

  function mintTokensByETHExternal(address to, uint _invested) public onlyDirectMintAgentOrOwner returns(uint) {
    return mintTokensByETH(to, _invested);
  }

  function mintTokensByETH(address to, uint _invested) internal isUnderHardcap returns(uint) {
    invested = invested.add(_invested);
    uint tokens = calculateTokens(_invested);
    mintTokens(to, tokens);
    return tokens;
  }

  function devWithdraw() internal {
    uint received = devWallet.balance;
    uint limit = devWallet.limit();
    if (received < limit) {
      uint shouldSend = limit.sub(received);
      uint value;
      if (msg.value < shouldSend) {
        value = msg.value;
      } else {
        value = shouldSend;
      }
      devWallet.transfer(value);
    }
  }

  function fallback() internal minInvestLimited(msg.value) returns(uint) {
    require(now >= start && now < endSaleDate());
    if (devWallet != address(0)) {
      devWithdraw();
    }
    wallet.transfer(this.balance);
    return mintTokensByETH(msg.sender, msg.value);
  }

  function () public payable {
    fallback();
  }

}

contract RetrieveTokensFeature is Ownable {

  function retrieveTokens(address to, address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(to, alienToken.balanceOf(this));
  }

}

contract ValueBonusFeature is PercentRateProvider {

  using SafeMath for uint;

  struct ValueBonus {
    uint from;
    uint bonus;
  }

  ValueBonus[] public valueBonuses;

  function addValueBonus(uint from, uint bonus) public onlyOwner {
    valueBonuses.push(ValueBonus(from, bonus));
  }

  function getValueBonusTokens(uint tokens, uint _invested) public view returns(uint) {
    uint valueBonus = getValueBonus(_invested);
    if (valueBonus == 0) {
      return 0;
    }
    return tokens.mul(valueBonus).div(percentRate);
  }

  function getValueBonus(uint value) public view returns(uint) {
    uint bonus = 0;
    for (uint i = 0; i < valueBonuses.length; i++) {
      if (value >= valueBonuses[i].from) {
        bonus = valueBonuses[i].bonus;
      } else {
        return bonus;
      }
    }
    return bonus;
  }

}

contract REPUCommonSale is ValueBonusFeature, RetrieveTokensFeature, CommonSale {


}

contract StagedCrowdsale is Ownable {

  using SafeMath for uint;

  struct Milestone {
    uint period;
    uint bonus;
  }

  uint public totalPeriod;

  Milestone[] public milestones;

  function milestonesCount() public view returns(uint) {
    return milestones.length;
  }

  function addMilestone(uint period, uint bonus) public onlyOwner {
    require(period > 0);
    milestones.push(Milestone(period, bonus));
    totalPeriod = totalPeriod.add(period);
  }

  function removeMilestone(uint8 number) public onlyOwner {
    require(number < milestones.length);
    Milestone storage milestone = milestones[number];
    totalPeriod = totalPeriod.sub(milestone.period);

    delete milestones[number];

    for (uint i = number; i < milestones.length - 1; i++) {
      milestones[i] = milestones[i+1];
    }

    milestones.length--;
  }

  function changeMilestone(uint8 number, uint period, uint bonus) public onlyOwner {
    require(number < milestones.length);
    Milestone storage milestone = milestones[number];

    totalPeriod = totalPeriod.sub(milestone.period);

    milestone.period = period;
    milestone.bonus = bonus;

    totalPeriod = totalPeriod.add(period);
  }

  function insertMilestone(uint8 numberAfter, uint period, uint bonus) public onlyOwner {
    require(numberAfter < milestones.length);

    totalPeriod = totalPeriod.add(period);

    milestones.length++;

    for (uint i = milestones.length - 2; i > numberAfter; i--) {
      milestones[i + 1] = milestones[i];
    }

    milestones[numberAfter + 1] = Milestone(period, bonus);
  }

  function clearMilestones() public onlyOwner {
    require(milestones.length > 0);
    for (uint i = 0; i < milestones.length; i++) {
      delete milestones[i];
    }
    milestones.length -= milestones.length;
    totalPeriod = 0;
  }

  function lastSaleDate(uint start) public view returns(uint) {
    return start + totalPeriod * 1 days;
  }

  function currentMilestone(uint start) public view returns(uint) {
    uint previousDate = start;
    for (uint i = 0; i < milestones.length; i++) {
      if (now >= previousDate && now < previousDate + milestones[i].period * 1 days) {
        return i;
      }
      previousDate = previousDate.add(milestones[i].period * 1 days);
    }
    revert();
  }

}

contract Presale is NextSaleAgentFeature, StagedCrowdsale, REPUCommonSale {

  function calculateTokens(uint _invested) internal returns(uint) {
    uint milestoneIndex = currentMilestone(start);
    Milestone storage milestone = milestones[milestoneIndex];
    uint tokens = _invested.mul(price).div(1 ether);
    uint valueBonusTokens = getValueBonusTokens(tokens, _invested);
    if (milestone.bonus > 0) {
      tokens = tokens.add(tokens.mul(milestone.bonus).div(percentRate));
    }
    return tokens.add(valueBonusTokens);
  }

  function finish() public onlyOwner {
    token.setSaleAgent(nextSaleAgent);
  }

  function endSaleDate() public view returns(uint) {
    return lastSaleDate(start);
  }

}