contract MyPasswordHint {
    string public hint;
    address public owner;
                     
    function MyPasswordHint() {
        hint = "";
        owner = msg.sender;
    }
    function setHint(string nHint) {
        if (msg.sender == owner) {
            hint = nHint;
        }
    }
    function kill() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}