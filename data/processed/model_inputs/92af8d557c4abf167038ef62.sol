contract Ownable {
      address public owner;


      event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


         
                                                                                             
                 
         
      function Ownable() {
        owner = msg.sender;
      }


         
                                                                   
         
      modifier onlyOwner() {
        require(msg.sender == owner);
        _;
      }


         
                                                                                         
                                                              
         
      function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));      
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
      }

    }

contract Crowdsale is Ownable {
    using SafeMath for uint;

    LoriToken public token;
    address public beneficiary = 0xdA6273CBF8DFB22f4A55A6F87bb1A91C57e578db;

    uint public collected;

    uint public preICOstartTime = 1507644000;                           
    uint public preICOendTime = 1508853600;                           
    uint public ICOstartTime = 1510322400;                          
    uint public ICOendTime = 1512396000;                             
    bool public crowdsaleFinished = false;

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);

    function Crowdsale() {
        token = new LoriToken();
    }

    function() payable {
        doPurchase();
    }

    function doPurchase() payable {
        assert((now > preICOstartTime && now < preICOendTime) || (now > ICOstartTime && now < ICOendTime));
        require(msg.value >= 0.01 * 1 ether);
        require(!crowdsaleFinished);

        uint tokens = msg.value * (now >= ICOstartTime ? 100 : 120);

        require(token.mint(msg.sender, tokens));
        require(beneficiary.send(msg.value));

        collected = collected.add(msg.value);

        NewContribution(msg.sender, tokens, msg.value);
    }

    function withdraw() onlyOwner {
        require(token.finishMinting());
        require(beneficiary.send(this.balance));
        token.transferOwnership(beneficiary);

        crowdsaleFinished = true;
    }
}