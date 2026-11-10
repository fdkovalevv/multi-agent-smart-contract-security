contract Owner {

                                            
    bool isInitiated = false;

               
    address creatorAddress;
    address ownerAddress;
    uint idCustomer;

           

               
    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

                                               
                 
    function Owner(address _ownerAddress, uint _idCustomer) {
        creatorAddress = msg.sender;
        ownerAddress = _ownerAddress;
        idCustomer = _idCustomer;
        isInitiated = true;
    }


    function updateOwner(address _newOwnerAddress)
      onlyBy(creatorAddress) {
        ownerAddress = _newOwnerAddress;
    }


                                        
                                                 
    function getInfos() constant returns(address, address, uint) {
        return (creatorAddress,
                ownerAddress,
                idCustomer
                );
    }

    function getInitiated() constant returns(bool) {
        return isInitiated;
    }
}