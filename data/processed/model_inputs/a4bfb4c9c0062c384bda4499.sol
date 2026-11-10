contract SignedDigitalAsset {
                                
    address owner = msg.sender;
                                                            
    string public name;
                                                                           
	mapping (bytes32 => string) digitalSignatures;

                          
	event JsonWebTokenAdded(string _digitalFingerprint, string _digitalSignature, uint256 _timestamp);
                                                                                         
    modifier isOwner() { if (msg.sender != owner) throw; _; }

                                                       
    function SignedDigitalAsset(string _name) {
        name = _name;
    }
                                                                                
	function add(string _digitalFingerprint, string _digitalSignature)
        isOwner {
        digitalSignatures[sha3(_digitalFingerprint)] = _digitalSignature;
                                          
        JsonWebTokenAdded(_digitalFingerprint, _digitalSignature, now);
	}

                                                                              
	function get(string _digitalFingerprint) public constant returns(string){
		return digitalSignatures[sha3(_digitalFingerprint)];
	}

                                                        
    function removeAssetContract()
        isOwner {
        selfdestruct(owner);
    }
}