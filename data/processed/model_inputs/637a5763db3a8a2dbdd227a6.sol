contract BoostContainer {
    using SafeMathForBoost for uint256;

                      
    address public multiSigAddress;
    bool public paused = false;

                  
    Boost public boost;

                                                           
    InfoForDeposit[] public arrayInfoForDeposit;

                                                          
    mapping(address => uint256) public mapCompletionNumberForWithdraw;

            
    event LogDepositForDividend(uint256 blockNumber, uint256 etherAountForDividend);
    event LogWithdrawal(address indexed tokenHolder, uint256 etherValue);
    event LogPause();
    event LogUnpause();

                                                
    struct InfoForDeposit {
        uint256 blockNumber;
        uint256 depositedEther;
    }

                                                  
    modifier isNotCompletedForWithdrawal(address _address) {
        require(mapCompletionNumberForWithdraw[_address] != arrayInfoForDeposit.length);
        _;
    }

                                                  
    modifier onlyMultiSig() {
        require(msg.sender == multiSigAddress);
        _;
    }

                                                                                 
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

                                                                             
    modifier whenPaused() {
        require(paused);
        _;
    }

                        
                                                       
                                                                           
    function BoostContainer(address _boostAddress, address _multiSigAddress) public {
        boost = Boost(_boostAddress);
        multiSigAddress = _multiSigAddress;
    }

                                                       
                                                                                                                 
    function depositForDividend(uint256 _blockNumber) public payable onlyMultiSig whenNotPaused {
        require(msg.value > 0);

        arrayInfoForDeposit.push(InfoForDeposit({blockNumber:_blockNumber, depositedEther:msg.value}));

        LogDepositForDividend(_blockNumber, msg.value);
    }

                                   
    function withdraw() public isNotCompletedForWithdrawal(msg.sender) whenNotPaused {

                                                          
        uint256 withdrawAmount = getWithdrawValue(msg.sender);

        require(withdrawAmount > 0);

                                                                               
        mapCompletionNumberForWithdraw[msg.sender] = arrayInfoForDeposit.length;

                           
        msg.sender.transfer(withdrawAmount);

                     
        LogWithdrawal(msg.sender, withdrawAmount);
    }

                                   
                                       
    function changeMultiSigAddress(address _address) public onlyMultiSig {
        require(_address != address(0));
        multiSigAddress = _address;
    }

                                                      
                                                 
    function getArrayInfoForDepositCount() public view returns (uint256 result) {
        return arrayInfoForDeposit.length;
    }

                               
                                                             
                                                        
    function getWithdrawValue(address _address) public view returns (uint256 withdrawAmount) {
        uint256 validNumber = mapCompletionNumberForWithdraw[_address];
        uint256 blockNumber;
        uint256 depositedEther;
        uint256 tokenAmount;

        for (uint256 i = 0; i < arrayInfoForDeposit.length; i++) {
            if (i < validNumber) {
                continue;
            }

                                                                          
            blockNumber = arrayInfoForDeposit[i].blockNumber;
            depositedEther = arrayInfoForDeposit[i].depositedEther;

                                                                                     
            tokenAmount = boost.balanceOfAt(_address, blockNumber);

                                                                      
            withdrawAmount = withdrawAmount.add(tokenAmount.mul(depositedEther).div(boost.totalSupply()));
        }
    }

                                                                                             
    function destroy() public onlyMultiSig whenPaused {
        selfdestruct(multiSigAddress);
    }

                                                                          
    function pause() public onlyMultiSig whenNotPaused {
        paused = true;
        LogPause();
    }

                                                                             
    function unpause() public onlyMultiSig whenPaused {
        paused = false;
        LogUnpause();
    }

                                                                                                      
                                                
                                                             
    function sendProfit(address _address, uint256 _amount) public isNotCompletedForWithdrawal(_address) onlyMultiSig whenPaused {
        require(_address != address(0));
        require(_amount > 0);

        mapCompletionNumberForWithdraw[_address] = arrayInfoForDeposit.length;

                           
        _address.transfer(_amount);

                     
        LogWithdrawal(_address, _amount);
    }
}