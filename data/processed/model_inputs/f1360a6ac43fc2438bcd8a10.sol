contract WHAuthorizeAddress {

    modifier noEther() {if (msg.value > 0) throw; _}

    event Authorize(address indexed dthContract, address indexed authorizedAddress);

                                                                           
                                                                              
                                                                           
    function authorizeAddress(address _authorizedAddress) noEther() {

                                                                                  
        if  (getCodeSize(msg.sender) == 0 || getCodeSize(_authorizedAddress) > 0) {
            throw;
        }

        Authorize(msg.sender, _authorizedAddress);
    }

    function() {
        throw;
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }
}