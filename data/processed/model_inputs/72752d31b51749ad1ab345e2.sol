contract EmojisanMarketplace {

    struct Auction {
        address owner;
        uint32 bidBlock;
        uint128 currentPrice;
    }

    struct User {
        uint32 bidBlock;
        uint128 balance;
    }

                        
                                                                              
    Emojisan public constant emojisan = Emojisan(0x1f18c0e37E4a53ad3f110B7E1554Da41F26c8281);

    uint[] public tokenByIndex;
    mapping (uint => Auction) public auction;
    mapping (address => User) public user;
    uint32 private auctionTime = 20000;

    address public whaleAddress;
    uint32 public whaleStartTime;
    uint128 public whaleBalance;
    uint32 private whaleWithdrawDelay = 80000;

    uint128 public ownerBalance;
    uint private constant ownerTokenId = 128512;

    function tokens() external view returns (uint[]) {
        return tokenByIndex;
    }

    function tokensCount() external view returns (uint) {
        return tokenByIndex.length;
    }

    function wantItForFree(uint tokenId) external {
                                                            
        require(block.number >= user[msg.sender].bidBlock + auctionTime);
                                           
        require(auction[tokenId].owner == address(this));
        auction[tokenId] = Auction({
            owner: msg.sender,
            bidBlock: uint32(block.number),
            currentPrice: 0
        });
        user[msg.sender].bidBlock = uint32(block.number);
        emojisan.mint(tokenId);
    }

    function wantItMoreThanYou(uint tokenId) external payable {
                                                            
        require(block.number >= user[msg.sender].bidBlock + auctionTime);
        Auction memory a = auction[tokenId];
                                            
        require(block.number < a.bidBlock + auctionTime);
        uint128 previousPrice = a.currentPrice;
                                        
                                                                           
                                                                            
        uint128 price;
        if (previousPrice == 0) {
            price = 2 finney;
        } else if (previousPrice < 500 finney) {
            price = 2 * previousPrice;
        } else {
            price = (previousPrice + 500 finney) / 500 finney * 500 finney;
        }
        require(msg.value >= price);
        uint128 priceDiff = price - previousPrice;
                                                     
        user[a.owner].balance += previousPrice + priceDiff / 4;
                               
        whaleBalance += priceDiff / 2;
                                                 
        ownerBalance += priceDiff / 4;
        auction[tokenId] = Auction({
            owner: msg.sender,
            bidBlock: uint32(block.number),
            currentPrice: price
        });
        user[a.owner].bidBlock = 0;
        user[msg.sender].bidBlock = uint32(block.number);
        if (msg.value > price) {
                                                         
            msg.sender.transfer(msg.value - price);
        }
    }

    function wantMyToken(uint tokenId) external {
        Auction memory a = auction[tokenId];
                                       
        require(block.number >= a.bidBlock + auctionTime);
        emojisan.transferFrom(this, a.owner, tokenId);
    }

    function wantMyEther() external {
        uint amount = user[msg.sender].balance;
        user[msg.sender].balance = 0;
        msg.sender.transfer(amount);
    }

    function wantToBeWhale() external {
                                                    
        require(emojisan.balanceOf(msg.sender) > emojisan.balanceOf(whaleAddress));
        whaleAddress = msg.sender;
                                                                                 
        whaleStartTime = uint32(block.number);
    }

    function whaleWantMyEther() external {
        require(msg.sender == whaleAddress);
                                                                                  
        require(block.number >= whaleStartTime + whaleWithdrawDelay);
        whaleStartTime = uint32(block.number);
        uint amount = whaleBalance;
        whaleBalance = 0;
        whaleAddress.transfer(amount);
    }

    function ownerWantMyEther() external {
        uint amount = ownerBalance;
        ownerBalance = 0;
        emojisan.ownerOf(ownerTokenId).transfer(amount);
    }

    function wantNewTokens(uint[] tokenIds) external {
                                         
        require(msg.sender == emojisan.ownerOf(ownerTokenId));
        for (uint i = 0; i < tokenIds.length; i++) {
            uint tokenId = tokenIds[i];
            auction[tokenId].owner = this;
            tokenByIndex.push(tokenId);
        }
    }

    function wantNewMinter(address minter) external {
                                         
        require(msg.sender == emojisan.ownerOf(ownerTokenId));
        emojisan.setMinter(minter);
    }

    function debug() external {
        require(msg.sender == emojisan.ownerOf(ownerTokenId));
        auctionTime = 1;
        whaleWithdrawDelay = 1;
    }
}