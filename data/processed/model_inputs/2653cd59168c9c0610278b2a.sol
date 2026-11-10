contract SignedDigitalAsset {
                                
    address owner = msg.sender;
                                                            
    string public name = "Test University";
                                                                           
	mapping (bytes32 => string) jsonWebTokens;

                          
	event JsonWebTokenAdded(bytes32 _digitalFingerprint, string _jsonWebToken, uint256 _timestamp);
                                                                                         
    modifier isOwner() { if (msg.sender != owner) throw; _; }

                                                                                
	function add(bytes32 _digitalFingerprint, string _jsonWebToken)
        isOwner {
        jsonWebTokens[_digitalFingerprint] = _jsonWebToken;
                                          
        JsonWebTokenAdded(_digitalFingerprint, _jsonWebToken, now);
	}

                                                                                   
	function get(bytes32 _digitalFingerprint) constant returns(string){
		return jsonWebTokens[_digitalFingerprint];
	}
}