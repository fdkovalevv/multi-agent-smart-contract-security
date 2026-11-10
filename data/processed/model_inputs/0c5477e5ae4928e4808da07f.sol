contract Factory {
    function newHangoutContract(address[] _hangoutGroup, address _registrationContract, uint _hangoutBegins, bytes32 _hangoutAddress) returns (address) {
      return new hangout(_hangoutGroup, _registrationContract, _hangoutBegins, _hangoutAddress);   
    }
    
}