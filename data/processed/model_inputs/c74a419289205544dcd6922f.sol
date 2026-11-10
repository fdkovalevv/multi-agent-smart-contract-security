contract RandomReality {

                                                                                                          
    address owner;

                                             
    address publisher;

                                                  
                                                       
                                              
    address emergency_brake;

                      
    uint256 fee = 2000000000000000;

                                              
    uint256 gas_price = 20000000000;

                                                                
    uint256 last_gas_price_increase_ts;
    uint256 last_fee_increase_ts;

                                                                                 
    bytes32 default_api_key;

    event LogRequest(bytes32 indexed request_id, address indexed sender, uint256 wait_blocks, uint256 wait_secs, uint256 min, uint256 max, uint256 counter, uint256 gas, bytes32 keccak_api_key);

    uint256 counter = 0;

    bool public isActive = false;
    
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    function RandomReality() {
        owner = msg.sender;
    }

    function updateOwner(address _addr) onlyOwner {
        owner = _addr;
    }

    function updateEmergencyBrake(address _addr) onlyOwner {
        emergency_brake = _addr;
    }

    function activate() onlyOwner {
        isActive = true;
    }

    function deactivate() {
        if ( (msg.sender != owner) && (msg.sender != emergency_brake) && (msg.sender != publisher) ) throw;
        isActive = false;
    }

    function setDefaultAPIKey(bytes32 api_key) onlyOwner {
        default_api_key = api_key;
    }

    function setGasPrice(uint256 _price) onlyOwner {
                                                                     
        if (_price > gas_price) {
            if ( (now - last_gas_price_increase_ts) < 1 days ) throw;
            last_gas_price_increase_ts = now;
        }
                                                           
        if ( _price > gas_price * 2 ) {
            throw;
        }
        gas_price = _price;
    }

    function getGasPrice() constant returns (uint256) {
        return gas_price;
    }

    function getFee() constant returns (uint256) {
        return fee;
    }

    function getPrice(uint256 gas) constant returns (uint256) {
        return fee + (gas_price * gas);
    }

    function setFee(uint256 _fee) onlyOwner {
                                                               
        if (_fee > fee) {
            if ( (now - last_fee_increase_ts) < 1 days ) throw;
            last_fee_increase_ts = now;
        }
                                                     
        if ( _fee > fee * 2 ) {
            throw;
        }
        fee = _fee;
    }

    function withdraw(address addr, uint256 amount) onlyOwner {
        bool r = addr.send(amount);
    }

    function setPublisher(address addr) onlyOwner {
        publisher = addr;
    }

                                                                          
                                                  
                                                                                                                                                     
                                                                                         

                                                                     
                                                                                                                 
                                                

                                                                                       
                                                                                                         
                                                     

                                                                                                
                                                                                                    

    function requestNumber(uint256 min, uint256 max, uint256 wait_blocks, uint256 wait_secs) payable returns (bytes32) {

        if (msg.value < fee) throw;
        if (min > max) throw;
        if (!isActive) throw;

        uint256 gas_amount = (msg.value - fee) / gas_price;
        counter++;

        bytes32 request_id = sha3(msg.sender, wait_blocks, wait_secs, min, max, counter, gas_amount, default_api_key, block.number, now); 

                                                                                                                       
                                                                       
                                                                                      
                                                                                    
                                                                                                                     

        LogRequest(request_id, msg.sender, wait_blocks, wait_secs, min, max, counter, gas_amount, default_api_key); 

        return request_id;

    }

                                                         
    function __random_callback(bytes32 request_id, uint256 val, uint256 err, bytes32 ipfs_proof) {}

}