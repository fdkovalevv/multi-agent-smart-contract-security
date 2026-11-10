contract AccessControl {
    using ECDSA for bytes32;
    mapping(address => bool) isAdmin;
    mapping(address => bool) isRegularUser;
                                                          
    function addUser(
        address user,
        bool admin,
        bytes calldata signature
    )
        external
    {
        if (!isAdmin[msg.sender]) {
                                                                   
            bytes32 hash = keccak256(abi.encodePacked(user));
            address signer = hash.toEthSignedMessageHash().recover(signature);
            require(isAdmin[signer], "Only admins can add users.");
        }
        if (admin) {
            isAdmin[user] = true;
        } else {
            isRegularUser[user] = true;
        }
    }
}