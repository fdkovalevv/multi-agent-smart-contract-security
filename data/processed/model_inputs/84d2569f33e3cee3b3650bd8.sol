contract Burner {

    function tokenFallback(address            , uint             , bytes            ) returns (bool result) {
        return true;
    }

}