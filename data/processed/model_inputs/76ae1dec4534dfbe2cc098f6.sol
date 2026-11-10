contract StakeTreeWithTokenization {
  using SafeMath for uint256;

  uint public version = 2;

  struct Funder {
    bool exists;
    uint balance;
    uint withdrawalEntry;
    uint contribution;
    uint contributionClaimed;
  }

  mapping(address => Funder) public funders;

  bool public live = true;                           
  uint public totalCurrentFunders = 0;                                
  uint public withdrawalCounter = 0;                                                        
  uint public sunsetWithdrawDate;
  
  MiniMeToken public tokenContract;
  MiniMeTokenFactory public tokenFactory;
  bool public tokenized = false;
  bool public canClaimTokens = false;

  address public beneficiary;                           
  uint public sunsetWithdrawalPeriod;                                                                                 
  uint public withdrawalPeriod;                                                 
  uint public minimumFundingAmount;                                                                  
  uint public lastWithdrawal;                        
  uint public nextWithdrawal;                        

  uint public contractStartTime;                           

  event Payment(address indexed funder, uint amount);
  event Refund(address indexed funder, uint amount);
  event Withdrawal(uint amount);
  event TokensClaimed(address indexed funder, uint amount);
  event Sunset(bool hasSunset);

  function StakeTreeWithTokenization(
    address beneficiaryAddress, 
    uint withdrawalPeriodInit, 
    uint withdrawalStart, 
    uint sunsetWithdrawPeriodInit,
    uint minimumFundingAmountInit) {

    beneficiary = beneficiaryAddress;
    withdrawalPeriod = withdrawalPeriodInit;
    sunsetWithdrawalPeriod = sunsetWithdrawPeriodInit;

    lastWithdrawal = withdrawalStart; 
    nextWithdrawal = lastWithdrawal + withdrawalPeriod;

    minimumFundingAmount = minimumFundingAmountInit;

    contractStartTime = now;
  }

              
  modifier onlyByBeneficiary() {
    require(msg.sender == beneficiary);
    _;
  }

  modifier onlyWhenTokenized() {
    require(isTokenized());
    _;
  }

  modifier onlyByFunder() {
    require(isFunder(msg.sender));
    _;
  }

  modifier onlyAfterNextWithdrawalDate() {
    require(now >= nextWithdrawal);
    _;
  }

  modifier onlyWhenLive() {
    require(live);
    _;
  }

  modifier onlyWhenSunset() {
    require(!live);
    _;
  }

    
                                                              
    
  function () payable {
    fund();
  }

    
                                               
                                                                              
    

  function fund() public payable onlyWhenLive {
    require(msg.value >= minimumFundingAmount);

                                                            
    if(!isFunder(msg.sender)) {
      totalCurrentFunders = totalCurrentFunders.add(1);                               

      funders[msg.sender] = Funder({
        exists: true,
        balance: msg.value,
        withdrawalEntry: withdrawalCounter,                                                                                                  
        contribution: 0,
        contributionClaimed: 0
      });
    }
    else { 
      consolidateFunder(msg.sender, msg.value);
    }

    Payment(msg.sender, msg.value);
  }

                   

    
                                                                   
                                                                     
                                                                               
                                                                             
                                                     
                                              
    
  function calculateWithdrawalAmount(uint startAmount) public returns (uint){
    return startAmount.mul(10).div(100);       
  }

    
                                                              
                                                                      
                                                    
                                              
    
  function calculateRefundAmount(uint amount, uint withdrawalTimes) public returns (uint) {    
    for(uint i=0; i<withdrawalTimes; i++){
      amount = amount.mul(9).div(10);
    }
    return amount;
  }

                     

    
                                                                            
                                                      
                                               
    

  function getRefundAmountForFunder(address addr) public constant returns (uint) {
                                                               
    if(shouldUpdateFunder(addr)) {
      uint amount = funders[addr].balance;
      uint withdrawalTimes = getHowManyWithdrawalsForFunder(addr);
      return calculateRefundAmount(amount, withdrawalTimes);
    }
    else {
      return funders[addr].balance;
    }
  }

  function getFunderContribution(address funder) public constant returns (uint) {
                                                               
    if(shouldUpdateFunder(funder)) {
      uint oldBalance = funders[funder].balance;
      uint newBalance = getRefundAmountForFunder(funder);
      uint contribution = oldBalance.sub(newBalance);
      return funders[funder].contribution.add(contribution);
    }
    else {
      return funders[funder].contribution;
    }
  }

  function getBeneficiary() public constant returns (address) {
    return beneficiary;
  }

  function getCurrentTotalFunders() public constant returns (uint) {
    return totalCurrentFunders;
  }

  function getWithdrawalCounter() public constant returns (uint) {
    return withdrawalCounter;
  }

  function getWithdrawalEntryForFunder(address addr) public constant returns (uint) {
    return funders[addr].withdrawalEntry;
  }

  function getContractBalance() public constant returns (uint256 balance) {
    balance = this.balance;
  }

  function getFunderBalance(address funder) public constant returns (uint256) {
    return getRefundAmountForFunder(funder);
  }

  function getFunderContributionClaimed(address addr) public constant returns (uint) {
    return funders[addr].contributionClaimed;
  }

  function isFunder(address addr) public constant returns (bool) {
    return funders[addr].exists;
  }

  function isTokenized() public constant returns (bool) {
    return tokenized;
  }

  function shouldUpdateFunder(address funder) public constant returns (bool) {
    return getWithdrawalEntryForFunder(funder) < withdrawalCounter;
  }

  function getHowManyWithdrawalsForFunder(address addr) private constant returns (uint) {
    return withdrawalCounter.sub(getWithdrawalEntryForFunder(addr));
  }

                             
  function setMinimumFundingAmount(uint amount) external onlyByBeneficiary {
    require(amount > 0);
    minimumFundingAmount = amount;
  }

  function withdraw() external onlyByBeneficiary onlyAfterNextWithdrawalDate onlyWhenLive  {
            
    uint amount = calculateWithdrawalAmount(this.balance);

              
    withdrawalCounter = withdrawalCounter.add(1);
    lastWithdrawal = now;                         
    nextWithdrawal = nextWithdrawal + withdrawalPeriod;                         

                  
    beneficiary.transfer(amount);

    Withdrawal(amount);
  }

                        
                                              
                                                                 
                                                                        
  function refund() external onlyByFunder {
            
    uint walletBalance = this.balance;
    uint amount = getRefundAmountForFunder(msg.sender);
    require(amount > 0);

              
    removeFunder();

                  
    msg.sender.transfer(amount);

    Refund(msg.sender, amount);

                                        
    assert(this.balance == walletBalance-amount);
  }

                                                                
                                                   
  function removeFunder() public onlyByFunder {
    delete funders[msg.sender];
    totalCurrentFunders = totalCurrentFunders.sub(1);
  }

    
                                                                         
                            
    

  function consolidateFunder(address funder, uint newPayment) private {
                          
    funders[funder].contribution = getFunderContribution(funder);
                     
    funders[funder].balance = getRefundAmountForFunder(funder).add(newPayment);
                              
    funders[funder].withdrawalEntry = withdrawalCounter;
  }

  function addTokenization(string tokenName, string tokenSymbol, uint8 tokenDecimals ) external onlyByBeneficiary {
    require(!isTokenized());

    tokenFactory = new MiniMeTokenFactory();
    tokenContract = tokenFactory.createCloneToken(0x0, 0, tokenName, tokenDecimals, tokenSymbol, true);

    tokenized = true;
    canClaimTokens = true;
  }

  function claimTokens() external onlyByFunder onlyWhenTokenized {
    require(canClaimTokens);

    uint contributionAmount = getFunderContribution(msg.sender);
    uint contributionClaimedAmount = getFunderContributionClaimed(msg.sender);

                                                        
    uint claimAmount = contributionAmount.sub(contributionClaimedAmount);
    require(claimAmount > 0);

                   
    funders[msg.sender].contributionClaimed = contributionAmount;
    tokenContract.generateTokens(msg.sender, claimAmount);

    TokensClaimed(msg.sender, claimAmount);
  }

    
                                                                      
                                                                                
    
  function enableTokenClaiming(bool _enabled) external onlyWhenTokenized onlyByBeneficiary {
    canClaimTokens = _enabled;
  }

                          
    
                                                           
                                                             
                                                                     
                                              
    

  function sunset() external onlyByBeneficiary onlyWhenLive {
    sunsetWithdrawDate = now.add(sunsetWithdrawalPeriod);
    live = false;

    Sunset(true);
  }

  function swipe(address recipient) external onlyWhenSunset onlyByBeneficiary {
    require(now >= sunsetWithdrawDate);

    recipient.transfer(this.balance);
  }

                                                              
     
                                                                              
               
                    
    
    
  function tokenContractClaimTokens(address _token) onlyByBeneficiary onlyWhenTokenized {
    tokenContract.claimTokens(_token);
  }
  function tokenContractEnableTransfers(bool _transfersEnabled) onlyByBeneficiary onlyWhenTokenized {
    tokenContract.enableTransfers(_transfersEnabled);
  }
}