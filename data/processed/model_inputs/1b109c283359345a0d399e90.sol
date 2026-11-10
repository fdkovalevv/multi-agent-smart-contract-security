contract multisig {
             

                                                             
                                                         
    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);

                                                        
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);

                                                                
    event RequirementChanged(uint newRequirement);

                                                           
    event Deposit(address _from, uint value);
                                                                                                               
    event SingleTransact(address owner, uint value, address to, bytes data);
                                                                                                                                           
    event MultiTransact(address owner, bytes32 operation, uint value, address to, bytes data);
                                                   
    event ConfirmationNeeded(bytes32 operation, address initiator, uint value, address to, bytes data);
}

contract Wallet is multisig {

                         
                                                                     
    function Wallet(address[] _owners, uint _required, uint _daylimit) {
                                                          
        bytes4 sig = bytes4(sha3("initWallet(address[],uint256,uint256)"));
        address target = _walletLibrary;

                                                           
                                                                    
                                       
        uint argarraysize = (2 + _owners.length);
        uint argsize = (2 + argarraysize) * 32;

        assembly {
                                                
            mstore(0x0, sig)
                                                            
                   
            codecopy(0x4,  sub(codesize, argsize), argsize)
                                           
            delegatecall(sub(gas, 10000), target, 0x0, add(argsize, 0x4), 0x0, 0x0)
        }
    }

              

                                                 
    function() payable {
                                     
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
        else if (msg.data.length > 0)
            _walletLibrary.delegatecall(msg.data);
    }

                                                                         
    function getOwner(uint ownerIndex) constant returns (address) {
        return address(m_owners[ownerIndex + 1]);
    }

                                                                            

    function hasConfirmed(bytes32 _operation, address _owner) constant returns (bool) {
        return _walletLibrary.delegatecall(msg.data);
    }

    function isOwner(address _addr) returns (bool) {
        return _walletLibrary.delegatecall(msg.data);
    }

             
    address constant _walletLibrary = 0x4f2875f631f4fc66b8e051defba0c9f9106d7d5a;

                                                                                  
    uint public m_required;
                                                   
    uint public m_numOwners;

    uint public m_dailyLimit;
    uint public m_spentToday;
    uint public m_lastDay;

                     
    uint[256] m_owners;
}