contract DelegateProxy {
     
                                                                                                                        
                                                                
                                                   
     
  function delegatedFwd(address _dst, bytes _calldata) internal {
    assembly {
      let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
      let size := returndatasize

      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)

                                                                                                           
                                                    
      switch result case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}

contract WalletStorage {
    address public owner;
}

contract WalletProxy is WalletStorage, DelegateProxy {
    event ReceivedETH(address from, uint256 amount);

    constructor() public {
        owner = msg.sender;
    }

    function() public payable {
        if (msg.value > 0) {
            emit ReceivedETH(msg.sender, msg.value);
        }
        if (gasleft() > 2400) {
            delegatedFwd(DelegateProvider(owner).getDelegate(), msg.data);
        }
    }
}