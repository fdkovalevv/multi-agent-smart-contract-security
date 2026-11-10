contract PoiFactory {
    function newPoiContract(address _proofOfIndividuality) returns (address) {
        return new POI(_proofOfIndividuality);
    }
}