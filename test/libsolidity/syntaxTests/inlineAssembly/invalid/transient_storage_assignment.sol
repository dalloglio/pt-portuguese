contract test {
    uint transient x;
    function f() public {
        assembly {
            x := 2
        }
    }
}
// ----
// TypeError 1408: (95-96): Only local variables are supported. To access storage variables, use the ".slot" and ".offset" suffixes.
