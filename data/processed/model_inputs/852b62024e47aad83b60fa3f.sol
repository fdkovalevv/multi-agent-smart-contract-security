contract MultiOwnable
{
    mapping(address => bool) public isAdmin;

    event LogAddAdmin(address whoAdded, address newAdmin);

    function addAdmin(address admin) public onlyAdmin returns (bool ok)
    {
        require(isAdmin[admin] == false);
        isAdmin[admin] = true;

        LogAddAdmin(msg.sender, admin);
        return true;
    }

    modifier onlyAdmin {
        require(isAdmin[msg.sender]);
        _;
    }
}

contract PredictionMarket is MultiOwnable
{
    using AddressSetLib for AddressSetLib.AddressSet;

    mapping(bytes32 => bool) public questionHasBeenAsked;
    AddressSetLib.AddressSet questions;

    event LogAddQuestion(address whoAdded, address questionAddress, string questionStr, uint betDeadlineBlock, uint finalizeStartTime);

    function PredictionMarket() {
        isAdmin[msg.sender] = true;
    }

    function kill(address recipient) public onlyAdmin returns (bool ok) {
        selfdestruct(recipient);
        return true;
    }

    function addQuestion(string questionStr, uint betDeadline, uint finalizeStartTime, string queryStr) 
        public 
        onlyAdmin 
        returns (bool ok, address questionAddr)
    {
        require(betDeadline > now);
        require(finalizeStartTime > betDeadline);

        bytes32 questionID = keccak256(questionStr);
        require(questionHasBeenAsked[questionID] == false);
        questionHasBeenAsked[questionID] = true;

        Question question = new Question(msg.sender, questionStr, betDeadline, finalizeStartTime, queryStr);
        questions.add(address(question));

        LogAddQuestion(msg.sender, address(question), questionStr, betDeadline, finalizeStartTime);

        return (true, address(question));
    }

    function removeQuestion(address addr) public onlyAdmin returns (bool ok) {
        questions.remove(addr);
        return (true);
    }

    function numQuestions() public view returns (uint) {
        return questions.size();
    }

    function getQuestionIndex(uint i) public view returns (address) {
        return questions.get(i);
    }

    function getAllQuestionAddresses() public view returns (address[]) {
        return questions.values;
    }
}