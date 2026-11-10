contract Remittance {
    uint withdrawalDelay = 60;                                      

    struct Deposit {
        address Sender;
        uint256 Balance;
        uint256 Deadline;
        bytes32 PublicKey;
        address Claimant;
        string PrivateKey1;
    }

    mapping (bytes32 => Deposit) Deposits;                          

    event deposited(address sender, bytes32 publicKey, uint amount);               
    event claimed(address claimant, address claimAddress, bytes32 publicKey, uint amount);             
    event withdrew(address withdrawer, uint blockTime, uint amount);                  
    
    function deposit(bytes32 _publicKey) public payable {
        require(Deposits[_publicKey].Balance == 0, "Already deposit with public key");                      
        Deposits[_publicKey] = Deposit(msg.sender, msg.value, block.number + withdrawalDelay, _publicKey, 0, "");               

        emit deposited(msg.sender, _publicKey, msg.value);                      
    }

    function claim(bytes32 _publicKey, string _privateKey1) public {
        require(msg.sender != Deposits[_publicKey].Sender, "Cannot claim own balance (request a withdrawal instead).");                      

        Deposits[_publicKey].Claimant = msg.sender;                
        Deposits[_publicKey].PrivateKey1 = _privateKey1;                     
    }

    function approveClaim(bytes32 _publicKey, string _privateKey2) public {
        require(Deposits[_publicKey].Claimant != msg.sender, "Cannot approve own claim.");                        
        require(Deposits[_publicKey].Sender == msg.sender, "Issuer must approve all claims.");                   
        require(keccak256(abi.encodePacked(Deposits[_publicKey].PrivateKey1, _privateKey2)) == Deposits[_publicKey].PublicKey, "Invalid private keys.");

        uint balance = Deposits[_publicKey].Balance;                 

        emit claimed(msg.sender, Deposits[_publicKey].Sender, Deposits[_publicKey].PublicKey, Deposits[_publicKey].Balance);

        Deposits[_publicKey].Balance = 0;                 

        msg.sender.transfer(balance);                                       
    }

    function withdraw(bytes32 _publicKey) public {
        uint balance = Deposits[_publicKey].Balance;                 

        require(block.number >= Deposits[_publicKey].Deadline, "Balance is not yet eligible for withdrawal.");                                 
        require(msg.sender == Deposits[_publicKey].Sender, "Non-owner cannot withdraw.");                                        

        emit withdrew(msg.sender, block.number, Deposits[_publicKey].Balance);                         

        Deposits[_publicKey].Balance = 0;                

        msg.sender.transfer(balance);                  
    }
}