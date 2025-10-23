# Understanding Prediction Markets: From DraftKings to Multiverse Finance

## Abstract

This doc examines the evolution of prediction markets through the lens of market structure, liquidity dynamics, and economic value transfer. By analyzing Kalshi's parlay data and comparing it to traditional sportsbook models, we identify how exchange-based prediction markets create value differently than traditional betting platforms. We then explore how this evolution might progress toward more sophisticated financial ecosystems.

## Introduction

The prediction market landscape is undergoing rapid transformation. What began as centralized sportsbooks with house-controlled outcomes is evolving toward decentralized exchanges and, potentially, entire conditional financial ecosystems. Understanding this progression requires examining not just the technology, but the fundamental economics of how value flows between participants.

## The Economics of "Fish Flow"

### Makers, Takers, and Expected Value

In any exchange, participants fall into two categories. Makers post limit orders and provide liquidity, waiting for counterparties. Takers accept existing orders and trade immediately[^1]. This distinction matters because makers systematically profit at takers' expense through better pricing and exchange rebates.

Expected value (EV) describes whether a bet is profitable over time. Positive EV positions make money on average; negative EV positions lose money. The spread—the gap between bid and ask prices—determines who captures value. When fair value is 61¢, makers might buy at 60¢ and sell at 62¢, while takers pay 62¢ to buy or accept 60¢ to sell[^2]. Over many trades, this small edge compounds significantly.

### The Hold Rate Metric

"Hold rate" measures what percentage of wagered money flows away from losing bettors. Traditional sportsbooks report this as revenue divided by handle (total amount wagered). An 8% hold rate means $8 disappears from every $100 wagered[^3].

This metric becomes complex in exchange models. When DraftKings reports 8% hold, that revenue goes entirely to the house. But exchanges like Kalshi only capture a fraction of the total value transfer—the rest flows to makers.

## Kalshi's Parlay Analysis

### Why Parlays Matter

Parlays—bets combining multiple events where all must occur to win—provide a unique analytical opportunity. Unlike standard prediction markets where contracts trade hands multiple times, parlay structure makes round-trip trading economically unfeasible due to combinatorial complexity and thin liquidity[^3]. This creates a "controlled environment where we can finally cleanly quantify the fish in sportsbook terms"[^3].

From September 29, 2024 through the article's publication, Kalshi's parlay data showed[^3]:
- $806,000 in handle (total wagered)
- $89,000 in taker losses (11% hold rate)
- ~$8,000 to Kalshi (1% in fees)
- ~$81,000 to makers (10% as spread profits)

### The Missing 10%

This analysis reveals what traditional metrics obscure. Spruce Point's short report attempted valuing Kalshi using sportsbook metrics, comparing Kalshi's 1% fee revenue to DraftKings' 8% hold[^3]. But this comparison misunderstands the value creation model.

DraftKings captures all value transfer as revenue because they're the counterparty to every bet. Kalshi facilitates value transfer between users, capturing only transaction fees while makers pocket the spread. The "fish flow"—money lost by recreational bettors—is comparable or superior (11% vs 8%), just distributed differently[^3].

As the analysis concludes: "Kalshi's parlay data proves exchanges can facilitate the same economic transfer—recreational bettors losing to sharps—without the overhead. No dealing with a state-by-state patchwork regulations. No cat-and-mouse game with profiling and limiting. Same fish, same flow, 90% less infrastructure and 10x the potential distribution through brokers in every country that allows futures trading"[^3].

## The Evolution of Market Freedom

### Step 0: House-Controlled Markets (DraftKings)

Traditional sportsbooks offer apparent liquidity through "cash out" features, but this masks fundamental control. DraftKings suspends cash out based on profitability calculations—"if their calculations show it's more profitable to let the bet ride, they may choose to keep the option off the table"[^4]. They also disable it during critical game moments, odds updates, or when promotional restrictions apply[^4].

This isn't market dynamics—it's discretionary gatekeeping by the house.

### Step 1: Free Markets with Geographic Constraints (Kalshi)

Kalshi represents the first true free market for complex event combinations in the US. Anyone can be maker or taker. Spreads are visible. Exit constraints stem from liquidity limitations, not house discretion. However, CFTC regulation limits access to US participants only[^5].

Post-election 2024 data shows Kalshi's challenge: daily active users dropped from 400,000 in November to 27,000-32,000 by mid-2025[^6]. The platform processed $2 billion in 2024 volume with 1.3 million unique users[^5].

### Step 2: Maximally Free Markets (Polymarket)

Polymarket's global accessibility addresses parlay's fundamental liquidity problem. The platform peaked at 314,500 monthly active users in December 2024 and processed $9 billion in annual volume[^7]. Though activity declined post-election (down 48% in monthly users by mid-2025), the absolute numbers remain substantially higher than Kalshi[^8].

For highly specific combinations—the essence of parlays—participant pool size directly determines liquidity viability. A bet on "Trump wins AND Dems take Senate AND GDP > 2%" might interest 10 people in a 10,000-user market but 300 in a 300,000-user market. Global access isn't just philosophically preferable; it's structurally necessary for complex markets to function.

Polymarket's geographic reach enables the critical mass required for step 2: liquid secondary markets where parlays become actively traded securities rather than buy-and-hold positions. However, this remains theoretical. As one analysis notes, "imagine a world where parlay contracts are traded around through RFQ or orderbook in the same way Credit Default Swaps are traded"—but this future would eliminate the clean data structure that currently makes fish measurement possible[^3].

#### The Conditional Tokens Framework

Polymarket's infrastructure relies on the Conditional Tokens Framework, a smart contract system developed by Gnosis that enables splitting collateral into outcome-contingent positions[^10]. This framework provides the technical foundation enabling both Step 2's liquid markets and Step 3's conditional financial ecosystems.

The framework addresses a fundamental problem in combinatorial prediction markets: fungibility across condition orderings. When multiple conditions nest (such as "Who wins?" AND "What's the score?"), naive implementations create different tokens depending on resolution order, even though these represent economically identical positions[^10]. Conditional Tokens solves this by centralizing all conditions in a single smart contract, ensuring "deeper-layer outcome tokens become truly fungible—the same token regardless of condition ordering"[^10].

**Core mechanisms:**

The system operates through four primary functions that mirror the split-recombine-settle pattern fundamental to conditional finance[^11]:

- **`prepareCondition(oracle, questionId, outcomeSlotCount)`**: Initializes a condition with an oracle address, question identifier, and number of possible outcomes (supporting binary through 256-way outcomes). The function derives a condition ID via `keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount))`[^11].

- **`splitPosition(collateralToken, parentCollectionId, conditionId, partition, amount)`**: Converts collateral or shallow positions into deeper positions by burning tokens in parent positions and minting tokens in target positions. For example, splitting 100 USDC on a binary Trump/Biden election creates two positions representing "USDC if Trump wins" and "USDC if Biden wins"[^11].

- **`mergePositions(collateralToken, parentCollectionId, conditionId, partition, amount)`**: Reverses splitting by burning tokens in deeper positions to recover collateral. Holding both "Trump-USDC" and "Biden-USDC" positions allows recombining them into regular USDC, since one outcome must occur[^11].

- **`redeemPositions(collateralToken, parentCollectionId, conditionId, indexSets)`**: After oracle resolution, token holders claim collateral based on reported outcomes. Winners redeem conditional tokens for full collateral value; losing positions become worthless[^11].

All positions exist as token IDs within a single ERC-1155 contract, where position identifiers are calculated via `keccak256(abi.encodePacked(collateralToken, collectionId))`. This architecture maximizes capital efficiency—one deployed contract handles all conditional markets—while supporting arbitrary nesting depth for complex multi-condition positions[^11].

**Enabling Step 2:**

Conditional Tokens enables Polymarket's liquid secondary markets by making parlay components tradeable. Rather than Kalshi's locked parlay contracts, users can split collateral into conditional positions and trade these positions on Polymarket's orderbook. A position representing "Trump wins AND Bitcoin > $105k AND S&P > 5000" becomes a tradeable token ID that can change hands before resolution, creating the liquid secondary markets the footnote envisioned[^3][^10].

**Foundation for Step 3:**

The framework provides the primitive necessary for multiverse finance: conditional tokens that can serve as collateral for further conditional operations. Because positions representing "USDC in the Trump-wins universe" are themselves tokens, they can theoretically back lending, liquidity provision, or any DeFi primitive—though this remains largely theoretical given ERC-1155's limited adoption in existing DeFi protocols compared to the ERC-20 standard[^11].

### Step 3: Multiverse Finance

Dave White's Multiverse Finance extends conditional claims to their logical extreme. Rather than simple terminal bets, conditional tokens become gateways to entire parallel financial systems. In the "Powell gets fired" universe, you could hold conditional USD, borrow conditional ETH against it, provide liquidity on conditional swaps, and stake in conditional yield farms—"limitless chains of composability"[^9].

The key insight: "there is no problem when using notFiredUSD as collateral to borrow, say notFiredETH. If Powell is suddenly fired, both your collateral and the asset you borrowed become worthless simultaneously, so there is no liquidation issue"[^9]. This enables entire financial ecosystems within each conditional universe, far beyond today's simple directional bets.

## Implementation Analysis: Conditional Tokens vs. Multiverse Vault Architecture

This repository is not intended as a full production alternative to the Conditional Tokens Framework. Rather, it represents a thought experiment exploring different architectural approaches to conditional token systems. The implementation was developed independently but converges on similar conceptual foundations as Conditional Tokens. Both systems implement the same financial primitive—splitting collateral into outcome-contingent positions that can be recombined—but make different architectural trade-offs that illuminate the design space for Step 3 multiverse finance applications.

### Convergent Design Patterns

Both implementations preserve the fundamental mathematical identity required for conditional finance:

```
1 unit collateral ⟷ 1 unit of EVERY outcome token
```

This equivalence guarantees that holding the complete set of outcome tokens equals holding the underlying collateral, enabling risk-free arbitrage to maintain price consistency across positions.

**Functional equivalence:**

| Operation | This Implementation | Conditional Tokens | Purpose |
|-----------|-------------------|-------------------|---------|
| Market creation | `MultiverseFactory.partition()` | `prepareCondition()` | Initialize new condition |
| Collateral splitting | `MultiverseVault.pushDown()` | `splitPosition()` | Convert collateral to conditional positions |
| Position recombination | `MultiverseVault.pullUp()` | `mergePositions()` | Recover collateral from complete position set |
| Settlement | `MultiverseVault.settle()` | `redeemPositions()` | Redeem winning positions post-resolution |

Both systems employ deterministic addressing to ensure positions are uniquely identifiable and prevent duplicates. The Conditional Tokens Framework computes position IDs via cryptographic hashing (`keccak256(collateralToken, collectionId)`), while this implementation uses CREATE2 for deterministic vault deployment with token addresses as immutable vault properties[^11].

### Architectural Divergence

The implementations differ fundamentally in their granularity and token standard choices, reflecting different optimization priorities:

**Token representation:**

- **This implementation**: Each conditional position deploys as an independent ERC-20 contract. A binary market on "Trump wins?" using USDC as collateral creates two separate ERC-20 contracts: `TrumpYES_USDC` and `TrumpNO_USDC`. Each position exists at its own contract address with human-readable names (`cd4dac45 YES WETH`)[^src].

- **Conditional Tokens**: All positions exist as token IDs within a single ERC-1155 contract. The same Trump market creates two position IDs (computed hashes) within one deployed contract. Position identifiers are deterministic but not human-readable[^11].

**Outcome flexibility:**

- **This implementation**: Hardcoded for binary outcomes (YES/NO). The vault contract explicitly defines `yesToken` and `noToken` as immutable addresses, with `pushDown()` minting exactly two token types[^src].

- **Conditional Tokens**: Supports arbitrary outcome counts (2 through 256 outcomes). The `prepareCondition()` function accepts `outcomeSlotCount` as a parameter, and `splitPosition()` operates on flexible partition arrays like `[0b001, 0b010, 0b100]` for three-way markets[^11].

**Deployment costs vs. composability:**

- **This implementation**: Higher deployment cost per market (one factory, one vault, two ERC-20 contracts per binary market), but each position is immediately compatible with all ERC-20-supporting DeFi protocols. A position token can be listed on Uniswap, deposited in Aave, or used in any ERC-20 context without protocol modifications.

- **Conditional Tokens**: Minimal deployment cost (single contract for all markets), but protocols must specifically integrate ERC-1155 support. While ERC-1155 is more capital efficient, it has significantly lower adoption in DeFi infrastructure compared to the ubiquitous ERC-20 standard[^11].

### Design Philosophy and Step 3 Implications

The architectural choices reflect different strategies for enabling multiverse finance ecosystems:

**Conditional Tokens optimizes for generality and efficiency:** By supporting N-way outcomes and nested conditions in a single contract, it provides a complete system for expressing complex conditional logic. However, the ERC-1155 standard creates friction for Step 3's vision of "entire financial systems within parallel universes"—existing lending protocols, AMMs, and yield farms predominantly support ERC-20 tokens.

**This implementation optimizes for composability and DeFi integration:** By representing each conditional position as a standalone ERC-20 contract, it trades deployment efficiency for immediate compatibility with the existing $100+ billion DeFi ecosystem. A `TrumpYES_USDC` token can serve as collateral in Aave, pair with `TrumpYES_WETH` in a Uniswap pool, or integrate with any protocol accepting ERC-20s—without requiring those protocols to modify their contracts or add ERC-1155 support.

For Step 3's goal of "conditional USD to borrow conditional ETH, provide liquidity on conditional swaps, and stake in conditional yield farms," the ERC-20 approach offers a more direct path to composability, while the ERC-1155 approach offers superior capital efficiency if protocols adopt the standard.

Both implementations successfully create the fundamental primitive—tradeable conditional positions—that bridges Step 2's liquid secondary markets and Step 3's conditional financial ecosystems. The choice between them represents a classic engineering trade-off: efficiency and generality versus immediate composability and ecosystem compatibility.

## Future Directions

### Polymarket's Parlay Evolution and the NFL Partnership

The theoretical framework presented here—particularly the progression from locked parlays to liquid secondary markets—faces practical testing through Polymarket's recent initiatives. The platform's partnership with the NFL represents a significant development for parlay market liquidity[^12].

Traditional prediction markets suffer from what we might call the "combinatorial liquidity problem": as condition complexity increases, potential participant pools shrink exponentially. A binary Trump election bet might attract millions of dollars in liquidity. A Trump-AND-Bitcoin parlay reduces that pool substantially. A Trump-AND-Bitcoin-AND-S&P parlay reduces it further still. This is why Kalshi's parlay data showed only $806,000 in handle despite the platform's overall volume—complex combinations simply lack depth[^3].

**The NFL liquidity test:**

Sports betting presents an interesting counterpoint. NFL games generate massive engagement with well-understood probabilities and clear resolution timeframes. If Polymarket can build liquid parlay markets anywhere, it will be here. The partnership provides several advantages:

- **High frequency**: 272 regular season games create continuous market opportunities rather than sporadic political events
- **Familiar correlations**: "Chiefs win AND over 50 points" resonates with casual bettors in ways that "Powell fired AND inflation spikes" does not
- **Established betting culture**: Unlike political prediction markets, sports parlays are already mainstream products with known demand

**Key questions for observation:**

1. **Does global access solve the liquidity problem?** Polymarket's 300,000+ user base dwarfs Kalshi's 30,000. Will this 10x difference translate to viable liquidity for complex NFL parlays (team X wins AND total score > Y AND player Z scores), or will combinatorial complexity still create thin markets?

2. **Can liquid secondary trading emerge?** The footnote's vision of parlay contracts trading like Credit Default Swaps requires two conditions: sufficient liquidity depth and sophisticated market makers. NFL markets may provide the first real test of whether prediction market parlays can achieve genuine secondary market liquidity rather than remaining buy-and-hold instruments.

3. **What hold rates emerge?** Kalshi's parlay data showed 11% hold (comparable to traditional sportsbooks). Does Polymarket's global model and Conditional Tokens infrastructure allow for tighter spreads through increased competition, or do the same "fish flow" economics persist at scale?

### Implications for Multiverse Finance

The NFL partnership serves as a proving ground for Step 2 → Step 3 progression. If Polymarket successfully creates liquid parlay markets with active secondary trading, it validates the fundamental assumption underlying multiverse finance: that conditional positions can function as tradeable assets rather than terminal bets.

More importantly, it would demonstrate whether the Conditional Tokens Framework's ERC-1155 architecture can achieve sufficient liquidity to serve as a foundation for conditional DeFi ecosystems. The alternative ERC-20 approach explored in this repository assumes conditional tokens will eventually need DeFi composability. But that assumption only matters if Step 2's liquid secondary markets can actually exist at scale.

The next 6-12 months of Polymarket's NFL markets will provide crucial data on whether complex conditional markets can overcome the combinatorial liquidity problem—and whether the path from tradeable parlays to entire conditional financial systems remains theoretical or becomes practical.

## Conclusion

The progression from DraftKings to potential Multiverse Finance represents increasing degrees of market freedom and sophistication:

1. **House control** → discrete permissions to exit positions
2. **Geographic constraints** → free markets limited by jurisdiction
3. **Global access** → maximum liquidity through borderless participation
4. **Conditional ecosystems** → entire financial systems within parallel universes

Each step builds on the previous, with market structure determining what's economically viable. Kalshi proved exchanges can capture comparable fish flow to traditional sportsbooks with vastly less infrastructure. Polymarket's global model addresses the liquidity requirements for complex combinations. And Multiverse Finance envisions what becomes possible when conditional claims evolve beyond terminal bets into composable financial primitives.

The data shows prediction markets aren't just about forecasting—they're laboratories for understanding value transfer, market structure, and the relationship between freedom and liquidity.

## References

[^1]: Optiver. "Bid-Ask Spread." July 29, 2022. https://optiver.com/explainers/bid-ask-spread/

[^2]: Bankrate. "Bid-Ask Spread: How It Works In Trading." April 17, 2025. https://www.bankrate.com/investing/what-is-bid-ask-spread/

[^3]: Fifty Cent Dollars. "The fish are the product." Substack. https://fiftycentdollars.substack.com/p/the-fish-are-the-product

[^4]: OddsAssist. "Cash Out Suspended on DraftKings? Reasons & Solutions." https://oddsassist.com/sports-betting/sportsbooks/draftkings/cash-out-unavailable-suspended-draftkings/

[^5]: Sacra. "Kalshi revenue, valuation & growth rate." https://sacra.com/c/kalshi/

[^6]: Fortune. "Polymarket and Kalshi see massive drop in users." July 24, 2025. https://fortune.com/2025/07/24/polymarket-and-kalshi-user-numbers/

[^7]: The Block. "Polymarket's huge year: $9 billion in volume and 314,000 active traders redefine prediction markets." January 3, 2025. https://www.theblock.co/post/333050/polymarkets-huge-year-9-billion-in-volume-and-314000-active-traders-redefine-prediction-markets

[^8]: The Block. "Polymarket hits $1.16 billion monthly volume but active trader count continues to fall." July 10, 2025. https://www.theblock.co/post/361370/polymarket-hits-1-16-billion-monthly-volume-but-active-trader-count-continues-to-fall

[^9]: White, Dave, Dan Robinson, and Ciamac Moallemi. "Multiverse Finance." Paradigm. May 12, 2025. https://www.paradigm.xyz/2025/05/multiverse-finance

[^10]: Gnosis. "Conditional Tokens: Motivation." Conditional Tokens Documentation. https://conditional-tokens.readthedocs.io/en/latest/motivation.html

[^11]: Gnosis. "Conditional Tokens: Developer Guide." Conditional Tokens Documentation. https://conditional-tokens.readthedocs.io/en/latest/developer-guide.html

[^src]: This repository. "MultiverseVault.sol" and "MultiverseFactory.sol." https://github.com/[repository-path]/src/

[^12]: Polymarket. "Polymarket Partners with the NFL." January 14, 2025. https://polymarket.com/blog/polymarket-partners-with-the-nfl