contract C {
    uint16 transient x;
    uint16 public transient y;
    uint256 public transient z;

    function f() public returns (uint256) {
        uint256 off1;
        uint256 off2;
        assembly {
            function f() -> o1 {
                tstore(z.slot, 7)
                o1 := y.offset
            }
            off2 := f()
        }
        assert(off2 == 2);
        return z;
    }
}
// ====
// EVMVersion: >=cancun
// compileViaYul: false
// ----
// f() -> 7
