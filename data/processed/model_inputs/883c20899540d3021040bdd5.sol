contract RegistrationFactory {
    function newRegistrationContract(uint _groupSize, uint _depositSize, uint _registrationPhase, uint _commitmentPhase, uint _hangoutPhase, address _hangoutFactory) returns (address) {
      return new Registration(_groupSize, _depositSize, _registrationPhase, _commitmentPhase, _hangoutPhase, _hangoutFactory);   
    }
    
}