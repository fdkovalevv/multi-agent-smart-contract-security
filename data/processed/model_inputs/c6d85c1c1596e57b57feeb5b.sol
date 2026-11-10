contract RandomRealityCaller {

    event MadeRequest(bytes32 id);
    event GotResponse(bytes32 request_id, uint256 val, uint256 err);

    address owner;

    function acceptFunds() payable {}

    function RandomRealityCaller() {
        owner = msg.sender;
    }

    function withdraw(address addr, uint256 amount) {
        if (owner != msg.sender) throw;
    }

    function testNumberRequest(address randomreality, uint256 min, uint256 max, uint256 blocks, uint256 secs) payable {
        RandomRealityAPI randomrealityapi = RandomRealityAPI(randomreality);
        uint256 cost = randomrealityapi.getPrice(200000);
        bytes32 id = randomrealityapi.requestNumber.value(cost)(min, max, blocks, secs);
        MadeRequest(id);
                                                                                
    }

    function __random_callback(bytes32 request_id, uint256 val, uint256 err, bytes32 ipfs_proof) {
        GotResponse(request_id, val, err);
    }

}