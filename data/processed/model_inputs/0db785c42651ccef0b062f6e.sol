contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

                                                                   
                                                                          
      
                                                                        
      
                                    
      
                                             
                                             
                                                   
                                      
      
                                          
                                          
      
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

contract ViewTokenMintage is DSAuth, DSMath {

    enum CategoryId {
        Team,
        Supporters,
        Creators,
        Bounties,
        SeedSale,
        MainSale
    }

    struct Category {
        uint mintLimit;
        uint amountMinted;
    }

    DSToken public viewToken;
    Category[6] public categories;

    event TokensMinted(
        address recipient,
        uint tokens,
        CategoryId category
    );

    function ViewTokenMintage(DSToken viewToken_) public {
        viewToken = viewToken_;

        uint MILLION = 1000000 ether;
        categories[uint8(CategoryId.Team)]       = Category(18 * MILLION, 0 ether);
        categories[uint8(CategoryId.Supporters)] = Category(9 * MILLION, 0 ether);
        categories[uint8(CategoryId.Creators)]   = Category(20 * MILLION, 0 ether);
        categories[uint8(CategoryId.Bounties)]   = Category(3 * MILLION, 113528 ether);
        categories[uint8(CategoryId.SeedSale)]   = Category(10 * MILLION, 10 * MILLION);
        categories[uint8(CategoryId.MainSale)]   = Category(40 * MILLION, 0 ether);

                                                                          
        assert(totalMintLimit() == 100 * MILLION);
    }

    function mint(address recipient, uint tokens, CategoryId categoryId) public auth {
        require(tokens > 0);
        Category storage category = categories[uint8(categoryId)];
        require(add(tokens, category.amountMinted) <= category.mintLimit);

        categories[uint8(categoryId)].amountMinted += tokens;
        viewToken.mint(this, tokens);
        viewToken.transferFrom(this, recipient, tokens);
        TokensMinted(recipient, tokens, categoryId);
    }

    function destruct(address addr) public auth {
        selfdestruct(addr);
    }

    function totalMintLimit() public view returns (uint total) {
      for (uint8 i = 0; i < categories.length; i ++) {
        total = add(total, categories[i].mintLimit);
      }

      return total;
    }
}