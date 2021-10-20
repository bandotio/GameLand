# GameLand
A GameFi NFT rent protocol.

Leveraging the blockchain game service market with experiential innovation

## Presentation
https://v.youku.com/v_show/id_XNTgwNjg2NzA5Ng==.html

## High-Level Concept (Abstract)
Gameland as a Gamefi platform aims to help users experience high-end games at the lowest price, provide users a rental platform with integrating experience and revenue, and lower the boundary between players and games。
This multi-dimensional enriches the blockchain game itself and brings new upgrades to the blockchain game


## Our Vision 
The Gameland vision is to bring affordable game experience with an NFT for trustless, secure, and quick rentability in cross-platform way by gathering all the rentable items like user accounts or tools from different online gaming platforms and list them in order for people who are interested in renting one or some of them for either fun game experience or profit. 
Moreover, we want the community to benefit from this. We aim to fulfill the vision of a true DAO where each member is rewarded, to the extent that they are active participants in the community. All of the Origin products will be under the umbrella of this DAO.
The initial and core Origin product is a protocol layer that enables peer to peer renting of ERC-721 non-fungible tokens (NFTs) on Ethereum Mainnet

Gameland architecture in future will be multi-chained as most of the different chain games are on different public chains.
The nature of NFT chain-crossing is different from the token one. Therefore, Gameland plan to establish multiple Chain Wallet smart contract leasing protocols on the platform to implement the cross chain NFT leasing system.


## Technology Stack
* Client Framework - React + Typescript 
* Ethereum development environment - Solidity + Hardhat
* Ethereum Web Client Library - Web3.js&Truffle/Ether.js&Waffle

## User Case(Ether only )
- Lenders(Lending an NFT)
* On Gameland’s platform a user can lend one or multiple NFTs. By doing so this saves multiple rental transaction costs and merges them into one single cost
* Lending implies transferring the NFT to our “escrow” smart contract to list it for rent
* The NFT "Lender" specifies the following:
    * The Rental Price (how much you wish to be compensated daily; this is the daily borrow price)
    * The NFT Price (this is the collateral a borrower most put up to rent)
    * Max Rental Period (maximum number of days you wish to lend out your NFT)

- Borrowers(Renting an NFT)
* The “Borrower” must specify the duration (in days) that they would like to borrow the NFT for
* This duration then gets multiplied by the lender's set rental price, the NFT price (collateral) gets added in, to arrive at the total rent price
* This total rent price gets deducted from the borrower’s balance and sent to the Gameland contract which acts as an escrow
* The NFT is then sent to the "Borrower" after successful transaction
* The NFT price (collateral) is stored in Gameland’s contract and is returned to the NFT “Borrower” only upon successful return of the NFT to the “Lender” (NFT "Lender")
* In the case that the NFT is not returned on time (rental duration has passed), the collateral can be claimed by the lender from the Gameland contract

## The process works as follow:
* Lenders fill up the name, nature of the item and upload the image of it.
* Gameland will then use the information above as a file and send it to IPFS to generate a CID
* The CID and the lender address will be the parameters to call our ERC721 contract to mint a NFT
* To call the functions at Gameland on UI, the NFT ID will be used to fetch the corresponding CID and the showcase will be rendered

## Road map 
Q3 2021
*  Testnet launch : including lending, borrowing, withdraw and liquidation etc.


Q4 2021
*  Bugs fixing and function optimizations: imposing a fine as penalty instead of confiscating the collaterals
*  Collateral Free Rentals: direct project integrations with NFT games/projects enabling collateral free renting
* L2 Solutions Support: Polygon
*  DAO Launch/Rollout : including Game Guild DAO and Gameland Governance DAO 
* Further blockchains/defi integrations (e.g: Aave and Compound):  according to market demands/activity
* Full Rental Statistics Dashboard
* Live leaderboard showing top renters and lenders (With special NFT rewards to gamify experience)

## Tentative Milestones
*  UI building (1week) & Testing
*  Testnet launch(2weeks) : including lending, borrowing, withdraw and liquidation etc. 
*  Bugs fixing and function optimizations(2weeks): imposing a fine as penalty instead of confiscating the collaterals

### Tentative future features
Origin Oracle has three roles: Game NFT aggregation, Game NFT Price Discoverer and Data Verification Node.
1. Firstly, the origin collection node collects the attributes of NFTs (e.g AXIS) with different scarcity and varieties and the transaction prices in the market in different periods through trading platforms such as Opensea, and the system forms a certain value evaluation standard model.
2. Secondly, the game NFT price discoverer collects the price of the market game NFT in the origin game Dao and feeds the price to the origin system. After the system collects the price, a unified database is formed. Everyone can participate in the Oracle service and become a node in the Oracle system network
3. The data verification node is responsible for data verification and storage, providing more secure and reliable data and reducing malicious quotations.
Dao governance mode, therefore, in the process of benchmarking the price range above, it is also necessary to carry out access constraints, governance and incentive measures for the corresponding participants, so that the dam can realize the quotation under normal rules and prevent quotation errors. So as to complete the pricing process of NFT
