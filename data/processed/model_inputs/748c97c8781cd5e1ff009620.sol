contract MultiSigWallet {

    uint constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address sender, bytes32 transactionHash);
    event Revocation(address sender, bytes32 transactionHash);
    event Submission(bytes32 transactionHash);
    event Execution(bytes32 transactionHash);
    event ExecutionFailure(bytes32 transactionHash);
    event Deposit(address sender, uint value);
    event OwnerAddition(address owner);
    event OwnerRemoval(address owner);
    event RequirementChange(uint required);

    mapping (bytes32 => Transaction) public transactions;
    mapping (bytes32 => mapping (address => bool)) public confirmations;
    mapping (bytes32 => uint) public nonces;
    mapping (address => bool) public isOwner;
    address[] public owners;
    bytes32[] public transactionHashes;
    uint public required;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        uint nonce;
        bool executed;
    }

    modifier onlyWallet() {
        if (msg.sender != address(this))
            throw;
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner])
            throw;
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner])
            throw;
        _;
    }

    modifier confirmed(bytes32 transactionHash, address owner) {
        if (!confirmations[transactionHash][owner])
            throw;
        _;
    }

    modifier notConfirmed(bytes32 transactionHash, address owner) {
        if (confirmations[transactionHash][owner])
            throw;
        _;
    }

    modifier notExecuted(bytes32 transactionHash) {
        if (transactions[transactionHash].executed)
            throw;
        _;
    }

    modifier notNull(address destination) {
        if (destination == 0)
            throw;
        _;
    }

    modifier validNonce(address destination, uint value, bytes data, uint nonce) {
        if (nonce > nonces[keccak256(destination, value, data)])
            throw;
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (   ownerCount > MAX_OWNER_COUNT
            || _required > ownerCount
            || _required == 0
            || ownerCount == 0)
            throw;
        _;
    }

                                                       
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

      
                       
       
                                                                                           
                                              
                                                          
    function MultiSigWallet(address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++)
            isOwner[_owners[i]] = true;
        owners = _owners;
        required = _required;
    }

                                                                             
                                          
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

                                                                             
                                      
    function removeOwner(address owner)
        public
        onlyWallet
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

                                                                                                         
                                                          
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

                                                                 
                                                      
                                             
                                             
                                                                                                  
                                                       
    function submitTransaction(address destination, uint value, bytes data, uint nonce)
        public
        returns (bytes32 transactionHash)
    {
        transactionHash = addTransaction(destination, value, data, nonce);
        confirmTransaction(transactionHash);
    }

                                                      
                                                              
    function confirmTransaction(bytes32 transactionHash)
        public
        ownerExists(msg.sender)
    {
        addConfirmation(transactionHash, msg.sender);
        executeTransaction(transactionHash);
    }

                                                                        
                                                              
    function revokeConfirmation(bytes32 transactionHash)
        public
        ownerExists(msg.sender)
        confirmed(transactionHash, msg.sender)
        notExecuted(transactionHash)
    {
        confirmations[transactionHash][msg.sender] = false;
        Revocation(msg.sender, transactionHash);
    }

                                                              
                                                              
    function executeTransaction(bytes32 transactionHash)
        public
        notExecuted(transactionHash)
    {
        if (isConfirmed(transactionHash)) {
            Transaction tx = transactions[transactionHash];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                Execution(transactionHash);
            else {
                ExecutionFailure(transactionHash);
                tx.executed = false;
            }
        }
    }

                                                              
                                                              
                                    
    function isConfirmed(bytes32 transactionHash)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionHash][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

                                                     
                                                      
                                             
                                             
                                                                                             
    function getNonce(address destination, uint value, bytes data)
        public
        constant
        returns (uint)
    {
        return nonces[keccak256(destination, value, data)];
    }

                                                              
                                                              
                                        
    function getConfirmationCount(bytes32 transactionHash)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionHash][owners[i]])
                count += 1;
    }

                                                                           
                                                    
                                                      
                                                                       
    function getTransactionCount(bool pending, bool executed)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<transactionHashes.length; i++)
            if (   pending && !transactions[transactionHashes[i]].executed
                || executed && transactions[transactionHashes[i]].executed)
                count += 1;
    }

      
                         
       
                                                                                                  
                                                      
                                             
                                             
                                                                                                  
                                                     
    function addTransaction(address destination, uint value, bytes data, uint nonce)
        internal
        notNull(destination)
        validNonce(destination, value, data, nonce)
        returns (bytes32 transactionHash)
    {
        transactionHash = keccak256(destination, value, data, nonce);
        if (transactions[transactionHash].destination == 0) {
            transactions[transactionHash] = Transaction({
                destination: destination,
                value: value,
                data: data,
                nonce: nonce,
                executed: false
            });
            nonces[keccak256(destination, value, data)] += 1;
            transactionHashes.push(transactionHash);
            Submission(transactionHash);
        }
    }

                                                                 
                                                              
                                      
    function addConfirmation(bytes32 transactionHash, address owner)
        internal
        notConfirmed(transactionHash, owner)
    {
        confirmations[transactionHash][owner] = true;
        Confirmation(owner, transactionHash);
    }

      
                     
       
                                    
                                        
    function getOwners()
        public
        constant
        returns (address[] _owners)
    {
        _owners = new address[](owners.length);
        for (uint i=0; i<owners.length; i++)
            _owners[i] = owners[i];
    }

                                                                             
                                                              
                                                 
    function getConfirmations(bytes32 transactionHash)
        public
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionHash][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

                                                                 
                                                              
                                                          
                                                    
                                                      
                                                    
    function getTransactionHashes(uint from, uint to, bool pending, bool executed)
        public
        constant
        returns (bytes32[] _transactionHashes)
    {
        bytes32[] memory transactionHashesTemp = new bytes32[](transactionHashes.length);
        uint count = 0;
        uint i;
        for (i=0; i<transactionHashes.length; i++)
            if (   pending && !transactions[transactionHashes[i]].executed
                || executed && transactions[transactionHashes[i]].executed)
            {
                transactionHashesTemp[count] = transactionHashes[i];
                count += 1;
            }
        _transactionHashes = new bytes32[](to - from);
        for (i=from; i<to; i++)
            _transactionHashes[i - from] = transactionHashesTemp[i];
    }
}