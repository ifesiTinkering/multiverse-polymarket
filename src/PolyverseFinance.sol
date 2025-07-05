// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/* ───────── UMA‑CTF adapter interface (Polymarket v3) ───────── */
interface IUmaCtfAdapter {
    /// Returns the final payout vector.  For binary markets the array is
    /// either [1,0] (YES wins) or [0,1] (NO wins).
    function getExpectedPayouts(bytes32 questionId)
        external
        view
        returns (uint256[] memory);
}

/* ----------  ERC‑20 verse token  ---------- */
contract VerseToken is ERC20 {
    address public immutable vault;

    constructor(string memory n, string memory s, address v)
        ERC20(n, s) { vault = v; }

    modifier onlyVault() { require(msg.sender == vault, "only vault"); _; }

    function mint(address to, uint256 amt) external onlyVault { _mint(to, amt); }
    function burn(address from, uint256 amt) external onlyVault { _burn(from, amt); }
}

/* ----------  Multiverse vault (binary only)  ---------- */
contract MultiverseVault {
    using SafeERC20 for IERC20;

    IERC20              public immutable parentToken;
    IUmaCtfAdapter      public immutable oracle;
    bytes32             public immutable questionId;

    address public immutable yesToken;
    address public immutable noToken;

    bool   public resolved;

    // 0 → YES verse won  (payout vector [1,0])
    // 1 → NO  verse won  (payout vector [0,1])
    uint8  public winningIndex;

    error NotBinaryResolution();
    error NotResolved();

    constructor(IERC20 _parentToken, IUmaCtfAdapter _oracle, bytes32 _qid) {
        parentToken = _parentToken;
        oracle      = _oracle;
        questionId  = _qid;

        string memory base = ERC20(address(_parentToken)).symbol();
        yesToken = address(
            new VerseToken(string(abi.encodePacked(base, "|YES")),
                           string(abi.encodePacked(base, "-Y")), address(this))
        );
        noToken  = address(
            new VerseToken(string(abi.encodePacked(base, "|NO")),
                           string(abi.encodePacked(base, "-N")), address(this))
        );
    }

    /* ----  BEFORE resolution  ---- */
    function pushDown(uint256 amt) external {
        parentToken.safeTransferFrom(msg.sender, address(this), amt);
        VerseToken(yesToken).mint(msg.sender, amt);
        VerseToken(noToken).mint(msg.sender, amt);
    }

    function pullUp(uint256 amt) external {
        VerseToken(yesToken).burn(msg.sender, amt);
        VerseToken(noToken).burn(msg.sender, amt);
        parentToken.safeTransfer(msg.sender, amt);
    }

    /* ----  AFTER resolution  ---- */
    function settle(uint256 amt) external {
        _syncResolution();
        if (winningIndex == 0) {
            VerseToken(yesToken).burn(msg.sender, amt);
        } else {
            VerseToken(noToken).burn(msg.sender, amt);
        }
        parentToken.safeTransfer(msg.sender, amt);
    }

    function _syncResolution() internal {
        if (resolved) return;

        uint256[] memory payouts;
        try oracle.getExpectedPayouts(questionId) returns (uint256[] memory p) {
            payouts = p;
        } catch {
            revert NotResolved();
        }

        // must be exactly two slots with a single 1
        if (payouts.length != 2) revert NotBinaryResolution();
        if (payouts[0] == 1 && payouts[1] == 0) winningIndex = 0;   // YES wins
        else if (payouts[0] == 0 && payouts[1] == 1) winningIndex = 1; // NO wins
        else revert NotBinaryResolution();

        resolved = true;
    }
}

/* ----------  Factory  ---------- */
contract MultiverseTokensFactory {
    event VaultCreated(
        IERC20   indexed parentToken,
        bytes32  indexed questionId,
        address  vault,
        address  yesToken,
        address  noToken
    );

    function partition(
        IERC20 parentToken,
        IUmaCtfAdapter oracle,
        bytes32 questionId
    )
        external
        returns (
            address vault,
            address yesToken,
            address noToken
        )
    {
        MultiverseVault v = new MultiverseVault(parentToken, oracle, questionId);
        vault    = address(v);
        yesToken = v.yesToken();
        noToken  = v.noToken();
        emit VaultCreated(parentToken, questionId, vault, yesToken, noToken);
    }
}
