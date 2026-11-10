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

contract StagedCrowdsale is Pausable {

  using SafeMath for uint;

  struct Stage {
    uint hardcap;
    uint price;
    uint invested;
    uint closed;
  }

  uint public start;

  uint public period;

  uint public totalHardcap;

  uint public totalInvested;

  Stage[] public stages;

  function stagesCount() public constant returns(uint) {
    return stages.length;
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }

  function setPeriod(uint newPeriod) public onlyOwner {
    period = newPeriod;
  }

  function addStage(uint hardcap, uint price) public onlyOwner {
    require(hardcap > 0 && price > 0);
    Stage memory stage = Stage(hardcap.mul(1 ether), price, 0, 0);
    stages.push(stage);
    totalHardcap = totalHardcap.add(stage.hardcap);
  }

  function removeStage(uint8 number) public onlyOwner {
    require(number >= 0 && number < stages.length);
    Stage storage stage = stages[number];
    totalHardcap = totalHardcap.sub(stage.hardcap);
    delete stages[number];
    for (uint i = number; i < stages.length - 1; i++) {
      stages[i] = stages[i+1];
    }
    stages.length--;
  }

  function changeStage(uint8 number, uint hardcap, uint price) public onlyOwner {
    require(number >= 0 && number < stages.length);
    Stage storage stage = stages[number];
    totalHardcap = totalHardcap.sub(stage.hardcap);
    stage.hardcap = hardcap.mul(1 ether);
    stage.price = price;
    totalHardcap = totalHardcap.add(stage.hardcap);
  }

  function insertStage(uint8 numberAfter, uint hardcap, uint price) public onlyOwner {
    require(numberAfter < stages.length);
    Stage memory stage = Stage(hardcap.mul(1 ether), price, 0, 0);
    totalHardcap = totalHardcap.add(stage.hardcap);
    stages.length++;
    for (uint i = stages.length - 2; i > numberAfter; i--) {
      stages[i + 1] = stages[i];
    }
    stages[numberAfter + 1] = stage;
  }

  function clearStages() public onlyOwner {
    for (uint i = 0; i < stages.length; i++) {
      delete stages[i];
    }
    stages.length -= stages.length;
    totalHardcap = 0;
  }

  function lastSaleDate() public constant returns(uint) {
    return start + period * 1 days;
  }

  modifier saleIsOn() {
    require(stages.length > 0 && now >= start && now < lastSaleDate());
    _;
  }

  modifier isUnderHardcap() {
    require(totalInvested <= totalHardcap);
    _;
  }

  function currentStage() public saleIsOn isUnderHardcap constant returns(uint) {
    for (uint i = 0; i < stages.length; i++) {
      if (stages[i].closed == 0) {
        return i;
      }
    }
    revert();
  }

}

contract CommonSale is StagedCrowdsale {

  address public masterWallet;

  address public slaveWallet;

  address public directMintAgent;

  uint public slaveWalletPercent;

  uint public percentRate = 100;

  uint public minPrice;

  uint public totalTokensMinted;

  StasyqToken public token;

  modifier onlyDirectMintAgentOrOwner() {
    require(directMintAgent == msg.sender || owner == msg.sender);
    _;
  }

  function setDirectMintAgent(address newDirectMintAgent) public onlyOwner {
    directMintAgent = newDirectMintAgent;
  }

  function setMinPrice(uint newMinPrice) public onlyOwner {
    minPrice = newMinPrice;
  }

  function setMasterWallet(address newMasterWallet) public onlyOwner {
    masterWallet = newMasterWallet;
  }

  function setToken(address newToken) public onlyOwner {
    token = StasyqToken(newToken);
  }

  function directMint(address to, uint investedWei) public onlyDirectMintAgentOrOwner saleIsOn {
    mintTokens(to, investedWei);
  }

  function createTokens() public whenNotPaused payable {
    require(msg.value >= minPrice);
    uint masterValue = msg.value.mul(percentRate.sub(slaveWalletPercent)).div(percentRate);
    uint slaveValue = msg.value.sub(masterValue);
    masterWallet.transfer(masterValue);
    slaveWallet.transfer(slaveValue);
    mintTokens(msg.sender, msg.value);
  }

  function mintTokens(address to, uint weiInvested) internal {
    uint stageIndex = currentStage();
    Stage storage stage = stages[stageIndex];
    uint tokens = weiInvested.mul(stage.price);
    token.mint(this, tokens);
    token.transfer(to, tokens);
    totalTokensMinted = totalTokensMinted.add(tokens);
    totalInvested = totalInvested.add(weiInvested);
    stage.invested = stage.invested.add(weiInvested);
    if (stage.invested >= stage.hardcap) {
      stage.closed = now;
    }
  }

  function() external payable {
    createTokens();
  }

  function retrieveTokens(address anotherToken, address to) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(to, alienToken.balanceOf(this));
  }


}

contract ITO is CommonSale {

  address public foundersTokensWallet;

  address public bountyTokensWallet;

  uint public foundersTokensPercent;

  uint public bountyTokensPercent;

  uint public lockPeriod;

  function ITO() public {
    addStage(2000,14500);
    addStage(2000,14000);
    addStage(2000,13500);
    addStage(2000,13000);
    addStage(2000,12500);
    addStage(2000,12000);
    addStage(2000,11500);
    addStage(2000,11000);
    addStage(2000,10500);
    addStage(2000,10000);
    masterWallet = 0x6715Feb90B78d4d7aD92FbaCA7Fd70481e12f836;
    slaveWallet = 0x8029618Ecb5445B73515d7C51AbB316A91FC7f23;
    slaveWalletPercent = 50;
    foundersTokensWallet = 0x95EA6A4ec9F80436854702e5F05d238f27166A03;
    bountyTokensWallet = 0x6715Feb90B78d4d7aD92FbaCA7Fd70481e12f836;
    start = 1525352400;
    period = 60;
    lockPeriod = 90;
    minPrice = 100000000000000000;
    foundersTokensPercent = 25;
    bountyTokensPercent = 5;
  }

  function setLockPeriod(uint newLockPeriod) public onlyOwner {
    lockPeriod = newLockPeriod;
  }

  function setFoundersTokensPercent(uint newFoundersTokensPercent) public onlyOwner {
    foundersTokensPercent = newFoundersTokensPercent;
  }

  function setBountyTokensPercent(uint newBountyTokensPercent) public onlyOwner {
    bountyTokensPercent = newBountyTokensPercent;
  }

  function setFoundersTokensWallet(address newFoundersTokensWallet) public onlyOwner {
    foundersTokensWallet = newFoundersTokensWallet;
  }

  function setBountyTokensWallet(address newBountyTokensWallet) public onlyOwner {
    bountyTokensWallet = newBountyTokensWallet;
  }

  function finishMinting() public whenNotPaused onlyOwner {
    uint summaryTokensPercent = bountyTokensPercent.add(foundersTokensPercent);
    uint mintedTokens = token.totalSupply();
    uint totalSupply = mintedTokens.mul(percentRate).div(percentRate.sub(summaryTokensPercent));
    uint foundersTokens = totalSupply.mul(foundersTokensPercent).div(percentRate);
    uint bountyTokens = totalSupply.mul(bountyTokensPercent).div(percentRate);
    token.mint(this, foundersTokens);
    token.lock(foundersTokensWallet, lockPeriod);
    token.transfer(foundersTokensWallet, foundersTokens);
    token.mint(this, bountyTokens);
    token.transfer(bountyTokensWallet, bountyTokens);
    totalTokensMinted = totalTokensMinted.add(foundersTokens).add(bountyTokens);
    token.finishMinting();
  }

}