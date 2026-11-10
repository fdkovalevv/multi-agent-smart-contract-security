contract IAccessControlled {

                            
             
                            

                                             
    event LogAccessPolicyChanged(
        address controller,
        IAccessPolicy oldPolicy,
        IAccessPolicy newPolicy
    );

                            
                       
                            

                                                                        
                                                                                                              
                                                                                                 
                                                                                 
                                                                    
                                                                                                                       
    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public;

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy);

}

contract StandardRoles {

                            
                
                            

                                                                 
                                                                                                                     
    bytes32 internal constant ROLE_ACCESS_CONTROLLER = 0xac42f8beb17975ed062dcb80c63e6d203ef1c2c335ced149dc5664cc671cb7da;
}

contract AccessControlled is IAccessControlled, StandardRoles {

                            
                    
                            

    IAccessPolicy private _accessPolicy;

                            
                
                            

                                                                                  
    modifier only(bytes32 role) {
        require(_accessPolicy.allowed(msg.sender, role, this, msg.sig));
        _;
    }

                            
                  
                            

    constructor(IAccessPolicy policy) internal {
        require(address(policy) != 0x0);
        _accessPolicy = policy;
    }

                            
                       
                            

      
                                   
      

    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public
        only(ROLE_ACCESS_CONTROLLER)
    {
                                                 
                                                   
                                                   
        require(newPolicy.allowed(newAccessController, ROLE_ACCESS_CONTROLLER, this, msg.sig));

                                                                      
        IAccessPolicy oldPolicy = _accessPolicy;
        _accessPolicy = newPolicy;

                    
        emit LogAccessPolicyChanged(msg.sender, oldPolicy, newPolicy);
    }

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy)
    {
        return _accessPolicy;
    }
}

contract AccessRoles {

                            
                
                            

                                                           
                                 
                                                                  

                                    
    bytes32 internal constant ROLE_NEUMARK_ISSUER = 0x921c3afa1f1fff707a785f953a1e197bd28c9c50e300424e015953cbf120c06c;

                                
    bytes32 internal constant ROLE_NEUMARK_BURNER = 0x19ce331285f41739cd3362a3ec176edffe014311c0f8075834fdd19d6718e69f;

                                          
    bytes32 internal constant ROLE_SNAPSHOT_CREATOR = 0x08c1785afc57f933523bc52583a72ce9e19b2241354e04dd86f41f887e3d8174;

                                              
    bytes32 internal constant ROLE_TRANSFER_ADMIN = 0xb6527e944caca3d151b1f94e49ac5e223142694860743e66164720e034ec9b19;

                                                                                
    bytes32 internal constant ROLE_RECLAIMER = 0x0542bbd0c672578966dcc525b30aa16723bb042675554ac5b0362f86b6e97dc5;

                                                                                                                                                     
    bytes32 internal constant ROLE_PLATFORM_OPERATOR_REPRESENTATIVE = 0xb2b321377653f655206f71514ff9f150d0822d062a5abcf220d549e1da7999f0;

                                                                                                             
    bytes32 internal constant ROLE_EURT_DEPOSIT_MANAGER = 0x7c8ecdcba80ce87848d16ad77ef57cc196c208fc95c5638e4a48c681a34d4fe7;

                                                                                              
    bytes32 internal constant ROLE_IDENTITY_MANAGER = 0x32964e6bc50f2aaab2094a1d311be8bda920fc4fb32b2fb054917bdb153a9e9e;

                                                                                                                       
    bytes32 internal constant ROLE_EURT_LEGAL_MANAGER = 0x4eb6b5806954a48eb5659c9e3982d5e75bfb2913f55199877d877f157bcc5a9b;

                                                                                  
    bytes32 internal constant ROLE_UNIVERSE_MANAGER = 0xe8d8f8f9ea4b19a5a4368dbdace17ad71a69aadeb6250e54c7b4c7b446301738;

                                                             
    bytes32 internal constant ROLE_GAS_EXCHANGE = 0x9fe43636e0675246c99e96d7abf9f858f518b9442c35166d87f0934abef8a969;

                                                                   
    bytes32 internal constant ROLE_TOKEN_RATE_ORACLE = 0xa80c3a0c8a5324136e4c806a778583a2a980f378bdd382921b8d28dcfe965585;

                                                                           
    bytes32 internal constant ROLE_DISBURSER = 0xd7ea6093d11d866c9e8449f8bffd9da1387c530ee40ad54f0641425bb0ca33b7;

                                                                          
    bytes32 internal constant ROLE_DISBURSAL_MANAGER = 0x677f87f7b7ef7c97e42a7e6c85c295cf020c9f11eea1e49f6bf847d7aeae1475;

}

contract Reclaimable is AccessControlled, AccessRoles {

                            
                
                            

    IBasicToken constant internal RECLAIM_ETHER = IBasicToken(0x0);

                            
                       
                            

    function reclaim(IBasicToken token)
        public
        only(ROLE_RECLAIMER)
    {
        address reclaimer = msg.sender;
        if(token == RECLAIM_ETHER) {
            reclaimer.transfer(address(this).balance);
        } else {
            uint256 balance = token.balanceOf(this);
            require(token.transfer(reclaimer, balance));
        }
    }
}