contract Owned {
                                                          
    modifier noEther() {if (msg.value > 0) throw; _}
                                                
    modifier onlyOwner { if (msg.sender != owner) throw; _ }

    address owner;

    function Owned() { owner = msg.sender;}



    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }

    function getOwner() noEther constant returns (address) {
        return owner;
    }
}

contract WHAuthorizeAddress is Owned {

    bool isClosed;

    mapping (address => bool) usedAddresses;

    event Authorize(address indexed dthContract, address indexed authorizedAddress);

    function WHAuthorizeAddress () {
        isClosed = false;
    }

                                                                           
                                                                              
                                                                           
    function authorizeAddress(address _authorizedAddress) noEther() {

                                                                         
        if (isClosed) {
            throw;
        }

                                                                                  
        if (getCodeSize(msg.sender) == 0 || getCodeSize(_authorizedAddress) > 0) {
            throw;
        }

                                                                                 
        if (usedAddresses[_authorizedAddress]) {
            throw;
        }
        usedAddresses[_authorizedAddress] = true;

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

                                                                                   
    function close() noEther onlyOwner {
        isClosed = true;
    }

    function getIsClosed() noEther constant returns (bool) {
        return isClosed;
    }
}