# GameLand

Now gameland support ERC721 & ERC1155(no batch function yet) NFT rent, repay, withdraw,confiscation

## Test NFT
- ERC721

You can use test721.sol in the contracts/ folder to mint nfts. or just use our testnet, which is not update to lastest version, comming soon.
- ERC1155 NFT

You can use test1155.sol in the contracts/ folder to mint nfts.

## Lender
If you are a lender, you can use our contract to mint 721 or 1155 nfts. then lend them out on Gameland.

### Prepare Stage
- Mint nft
 
 *ERC721
    
    mint(address to, uint256 tokenId)
    
    The first para is your own address, the second para is the nft id, which is the only identifier in nft contracts. you should remeber it for next move.
 *ERC1155 
    
    mint(address to,uint256 id,uint256 amount, bytes memory data): 
    
    The first para is your own address, the second para is the nft id just like the ERC721. The third para should always be 1.just leave the last para "".
    
- Approve To Gameland

You should approve to Gameland contract to finish the lending or the repaying. If some thing go wrong. Make sure you have approved Gameland to access your NFT.
 
 *ERC721
 
  approve(address to, uint256 tokenId)
  
  The first para is Gameland contract address. The second para is the nft id, which is the second para when  you mint nft.
 
 *ERC1155 
 
 setApprovalForAll(address operator, bool approved)
 
 The first para is Gameland contract address. the second para should be true.

After you finish the prepare stage, you are ready to do the next. As a lender you can do three things. 

Lend your nft to others

Withdraw if you do not want to lend it (only when the nft is still no lend out)

Confiscate borrower, if he/she overdue. But be careful, confiscation means you accept the amount of the asset the borrower put as the collateral for selling your nft.

- Lend

deposit(
uint256 daily_price, //price per day, in ether
uint256 duration,   //how long do you want to lend out
uint256 nft_id,       //The NFT you want to land out
uint256 collatoral, //How much do you want for collatoral, if the borrower overdue, or refuse to return your NFT, you can confiscation borrower. So be sure it's a appropriate price.
address nft_programe_address, //NFT programe contract address
uint256 gameland_nft_id   //Gameland support multple nft programes, so to distinguish different NFT programes, we give every progarme a number.
if you are test, just be sure give different number to different NFT programes.
)

withdraw
you can only withdraw your own nft, when no one is borrowing  it.

withdrawnft(
uint256 nft_id,  //the NFT you want to withdraw
address nft_programe_address,  //NFT programe contract address
uint256 gameland_nft_id //The id you give to it, when you deposit your nft.
)

confiscation
you can only confiscate the collateral when rent is overdue.

confiscation(uint256 gameland_nft_id) // the NFT you want to confiscate

## Borrower

As a borrower, you can borrow 721 or 1155 nfts in Gameland  by choosing the nft item then rent it and make sure return it in time or you might be confiscated.

rent(
uint256 nft_id,  //the NFT id you want to borrow
address nft_programe_address,  //NFT programe contract address
uint256 gameland_nft_id //the nft id in Gameland, if you use testnet you should not be worry, since a friendly UI can help you. but if you are test, just be sure you know the id in Gameland.
)

returnnft(
uint256 nft_id, //the NFT id you return
address nft_programe_address, //NFT programe contract address
uint256 gameland_nft_id //the nft id in Gameland, if you use testnet you should not be worry, since a friendly UI can help you. but if you are test, just be sure you know the id in Gameland.
)
