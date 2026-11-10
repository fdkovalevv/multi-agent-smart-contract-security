contract Factory {
    
    function newDepositContract(address _depositGovernance, address _registrationContract) returns (address) {
        return new RegistrationDeposits(_depositGovernance, _registrationContract);
    }
    
}