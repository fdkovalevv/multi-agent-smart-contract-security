contract Ownable {
    address public owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract RefStorage is Ownable {

    IERC20 public token;

    mapping (address => bool) public contracts;

    uint256 public prize = 0.00005 ether;
    uint256 public interval = 100;

    mapping (address => Player) public players;
    struct Player {
        uint256 tickets;
        uint256 checkpoint;
        address referrer;
    }

    event ReferrerAdded(address player, address referrer);
    event BonusSent(address recipient, uint256 amount);

    modifier restricted() {
        require(contracts[msg.sender]);
        _;
    }

    constructor() public {
        token = IERC20(address(0x9f9EFDd09e915C1950C5CA7252fa5c4F65AB049B));
    }

    function changeContracts(address contractAddr) public onlyOwner {
        contracts[contractAddr] = true;
    }

    function changePrize(uint256 newPrize) public onlyOwner {
        prize = newPrize;
    }

    function changeInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }

    function newTicket() external restricted {
        players[tx.origin].tickets++;
        if (players[tx.origin].referrer != address(0) && (players[tx.origin].tickets - players[tx.origin].checkpoint) % interval == 0) {
            if (token.balanceOf(address(this)) >= prize * 2) {
                token.transfer(tx.origin, prize);
                emit BonusSent(tx.origin, prize);
                token.transfer(players[tx.origin].referrer, prize);
                emit BonusSent(players[tx.origin].referrer, prize);
            }
        }
    }

    function addReferrer(address referrer) external restricted {
        if (players[tx.origin].referrer == address(0) && players[referrer].tickets >= interval && referrer != tx.origin) {
            players[tx.origin].referrer = referrer;
            players[tx.origin].checkpoint = players[tx.origin].tickets;

            emit ReferrerAdded(tx.origin, referrer);
        }
    }

    function sendBonus(address winner) external restricted {
        if (token.balanceOf(address(this)) >= prize) {
            token.transfer(winner, prize);

            emit BonusSent(winner, prize);
        }
    }

    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {
        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).transfer(recipient, amount);
    }

    function ticketsOf(address player) public view returns(uint256) {
        return players[player].tickets;
    }

    function referrerOf(address player) public view returns(address) {
        return players[player].referrer;
    }
}