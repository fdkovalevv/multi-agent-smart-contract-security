contract LoanContract {
                      
    address borrowerAddress;
    uint public loanAmount;
    uint public fundRaisingDeadline;
    uint public repaymentDeadline;
    
                 
    uint public numLenders;
    uint public amountRaised;
    uint public amountRepaid;
    uint public minimumLendAmount = 500000000000000000;
                                                                                                                   
    address[] public lenderAddresses;
    mapping(address => LenderAccount) public lenderAccounts;
    enum State {raising, funded, repaying, repaid, expired}           
    State public currentState;
    struct LenderAccount {
        uint amountLent;
        uint amountRepaid;
    }
    
            
    event LentToLoan(address addr, uint amount);
    event DisbursedToBorrower(address addr, uint amount);
    event RepaidByBorrower(address addr, uint amount);
    event RepaidToLender(address addr, uint amount);
    event SentBack(address addr, uint amount);
    event LoanFunded();
    event LoanExpired();
    event LoanRepaid();
    
                  
    function LoanContract(
        address _borrowerAddress, 
        uint loanAmountInEthers,
        uint fundRaisingDurationInDays,
        uint repaymentDurationInDays 
    ) {
        borrowerAddress = _borrowerAddress;
        loanAmount = loanAmountInEthers * 1 ether;
        fundRaisingDeadline = now + fundRaisingDurationInDays * 1 days;
        repaymentDeadline = fundRaisingDeadline + repaymentDurationInDays * 1 days;
    }

                                                                                                   
    function() payable {
        if (currentState == State.raising) {
            lend();
        } else if (currentState == State.repaying) {
            repay();
        } else {
            throw;
        }
    }
    
                                                                    
    function lend() private {
                                        
        if (msg.sender == borrowerAddress) {
            throw;
        }
                                  
        if (msg.value > amountLeftToFund()) {
            throw;
        }
                                                                                                        
        if (msg.value < minimumLendAmount && msg.value != amountLeftToFund()) {
            throw;
        }
        
                                      
        if (lenderAccounts[msg.sender].amountLent == 0) {
            numLenders++;
            lenderAddresses.push(msg.sender);
            lenderAccounts[msg.sender] = LenderAccount(msg.value, 0);
        } else {
            lenderAccounts[msg.sender].amountLent += msg.value;
        }
        
        amountRaised += msg.value;
        LentToLoan(msg.sender, msg.value);
        
        checkLoanFunded();
    }
    
                                                          
                                                                             
    function checkLoanFunded() private {
        if (amountRaised >= loanAmount) {
            LoanFunded();
            if (borrowerAddress.send(amountRaised)) {
                currentState = State.repaying;
                DisbursedToBorrower(borrowerAddress, amountRaised);
            }                    
        }
    }
    
                                                                         
    function repay() private {
                                                                              
        if (msg.sender != borrowerAddress) {
            throw;
        }
        if (msg.value > amountLeftToRepay()) {
            throw;
        }
        
        amountRepaid += msg.value;
        RepaidByBorrower(borrowerAddress, msg.value);
        
                                                                                               
        uint amountToDistribute = msg.value;
        uint amountDistributed = 0;
        for (uint i = 0; i < lenderAddresses.length; i++) {
            address currentLender = lenderAddresses[i];
            uint amountForLender = getAmountForLender(amountToDistribute, lenderAccounts[currentLender]);
            if (amountForLender > 0) {
                if (currentLender.send(amountForLender)) {
                    RepaidToLender(currentLender, amountForLender);
                    lenderAccounts[currentLender].amountRepaid += amountForLender;
                    amountDistributed += amountForLender;
                }                                                                                               
            }
        }
        
        checkLoanRepaid();
    }
    
    function getAmountForLender(uint amountToDistribute, LenderAccount account) private returns (uint) {
        if (amountRepaid != loanAmount) {
                                                                           
            return (amountToDistribute * account.amountLent) / loanAmount;
        } else {
                                                                   
            return account.amountLent - account.amountRepaid;
        }
    }
    
    function checkLoanRepaid() private {
        if (amountRepaid == loanAmount) {
            currentState = State.repaid;
            LoanRepaid();
        }
    }
    
                                   
    
    function amountLeftToFund() constant returns (uint) {
        return loanAmount - amountRaised;
    }
    
    function amountLeftToRepay() constant returns (uint) {
        return loanAmount - amountRepaid;
    }
    
    function isDelinquent() constant returns (bool) {
        return (now >= repaymentDeadline && currentState != State.repaid);
    }
    
                                                             
                                                                  
    function makeExpired() {
         if (now >= fundRaisingDeadline && currentState != State.expired) {
            currentState = State.expired;
            LoanExpired();
            for (uint i = 0; i < lenderAddresses.length; i++) {
                address currentLender = lenderAddresses[i];
                if (currentLender.send(lenderAccounts[currentLender].amountLent)) {
                    RepaidToLender(currentLender, lenderAccounts[currentLender].amountLent);
                }                    
            }
        }
    }
}