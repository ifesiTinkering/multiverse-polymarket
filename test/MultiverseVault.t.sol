// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/MultiverseFactory.sol";

/* ----------  Mock parent ERC‑20 (mintable)  ---------- */
contract TestERC20 is ERC20 {
    uint8 private _dec;
    constructor(string memory n, string memory s, uint8 d)
        ERC20(n, s) { _dec = d; }
    function mint(address to, uint256 amt) external { _mint(to, amt); }
    function decimals() public view override returns (uint8) { return _dec; }
}

/* --- oracle mock implementing getExpectedPayouts --- */
contract OracleMock is IUmaCtfAdapter {
    bool            private _resolved;
    uint256[2]      private _payouts;   // fixed‑size for simplicity

    function resolve(uint8 winner) external {
        require(winner == 0 || winner == 1, "bad winner input");
        _payouts = winner == 0 ? [uint256(1), uint256(0)] : [uint256(0), uint256(1)];
        _resolved = true;
    }

    function getExpectedPayouts(bytes32) external view returns (uint256[] memory p) {
        require(_resolved, "not resolved");
        p = new uint256[](2);
        p[0] = _payouts[0];
        p[1] = _payouts[1];
    }
}
/* ----------  Test suite  ---------- */
contract MultiverseVaultTest is Test {
    TestERC20                 parent;
    OracleMock                oracle;
    MultiverseFactory         factory;
    MultiverseVault           vault;
    IERC20                    yes;
    IERC20                    no;

    bytes32 constant QID = keccak256("dummy-qid");

    function setUp() public {
        parent  = new TestERC20("Wrapped ETH", "WETH", 18);
        oracle  = new OracleMock();
        factory = new MultiverseFactory();

        (address vaultAddr, address yesT, address noT) =
            factory.partition(parent, oracle, QID);

        vault = MultiverseVault(vaultAddr);
        yes   = VerseToken(yesT);
        no    = VerseToken(noT);

        parent.mint(address(this), 1 ether);
        parent.approve(vaultAddr, type(uint256).max);
        yes.approve(vaultAddr, type(uint256).max);
        no.approve(vaultAddr, type(uint256).max);
    }

    /* ----------  pushDown  ---------- */
    function testPushDownLocksCollateralAndMintsVerse() public {
        vault.pushDown(1 ether);

        assertEq(parent.balanceOf(address(vault)), 1 ether, "vault WETH");
        assertEq(yes.balanceOf(address(this)),     1 ether, "YES minted");
        assertEq(no.balanceOf(address(this)),      1 ether, "NO minted");
    }

    /* ----------  pullUp  ---------- */
    function testPullUpReturnsCollateral() public {
        vault.pushDown(1 ether);
        vault.pullUp(0.4 ether);

        assertEq(parent.balanceOf(address(this)), 0.4 ether, "received WETH back");
        assertEq(yes.balanceOf(address(this)),     0.6 ether, "YES burned");
        assertEq(no.balanceOf(address(this)),      0.6 ether, "NO burned");
    }

    /* ----------  settle (winner = NO)  ---------- */
    function testSettleBurnsOnlyWinningVerse() public {
        vault.pushDown(1 ether);

        oracle.resolve(1);             // winning index = 1 (NO)
        vault.settle(0.5 ether);

        assertEq(parent.balanceOf(address(this)), 0.5 ether, "settled WETH");
        assertEq(no.balanceOf(address(this)),      0.5 ether, "NO burned");
        assertEq(yes.balanceOf(address(this)),     1 ether,   "YES untouched");
    }
}
