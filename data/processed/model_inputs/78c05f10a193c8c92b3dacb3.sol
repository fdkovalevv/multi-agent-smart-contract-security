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


     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract VeTokenizedAssetRegistry is Ownable {

                     

    struct Asset {
        address addr;
        string meta;
    }

                 

    mapping (string => Asset) assets;

                     

    function VeTokenizedAssetRegistry()
        Ownable
    {
    }

                

    event AssetCreated(
        address indexed addr
    );

    event AssetRegistered(
        address indexed addr,
        string symbol,
        string name,
        string description,
        uint256 decimals
    );

    event MetaUpdated(string symbol, string meta);

                                  

    function create(
        string symbol,
        string name,
        string description,
        uint256 decimals,
        string source,
        string proof,
        uint256 totalSupply,
        string meta
    )
        public
        onlyOwner
        returns (address)
    {
        VeTokenizedAsset asset = new VeTokenizedAsset();
        asset.setup(
            symbol,
            name,
            description,
            decimals,
            source,
            proof,
            totalSupply
        );

        asset.transferOwnership(msg.sender);

        AssetCreated(asset);

        register(
            asset,
            symbol,
            name,
            description,
            decimals,
            meta
        );

        return asset;
    }

    function register(
        address addr,
        string symbol,
        string name,
        string description,
        uint256 decimals,
        string meta
    )
        public
        onlyOwner
    {
        assets[symbol].addr = addr;

        AssetRegistered(
            addr,
            symbol,
            name,
            description,
            decimals
        );

        updateMeta(symbol, meta);
    }

    function updateMeta(string symbol, string meta) public onlyOwner {
        assets[symbol].meta = meta;

        MetaUpdated(symbol, meta);
    }

    function getAsset(string symbol) public constant returns (address addr, string meta) {
        Asset storage asset = assets[symbol];
        addr = asset.addr;
        meta = asset.meta;
    }
}