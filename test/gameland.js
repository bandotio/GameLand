const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Gameland", function () {
    // Mocha has four functions that let you hook into the the test runner's
    // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

    // They're very useful to setup the environment for tests, and to clean it
    // up after they run.

    // A common pattern is to declare some variables, and assign them in the
    // `before` and `beforeEach` callbacks.
    // beforeEach(async function () {

    //     [owner, borrower] = await ethers.getSigners();
    // });

    let Nft;
    let hardhatNft;
    let Gameland;
    let hardhatGameland;
    let owner;
    let borrower;
    let provider;

    it("Should set rigiht testnft address", async function () {

        [owner, borrower] = await ethers.getSigners();
        
        Nft = await ethers.getContractFactory("MyNFT");
        hardhatNft = await Nft.deploy();
        await hardhatNft.deployed();
        provider  = ethers.provider;
        Gameland = await ethers.getContractFactory("GameLand");
        hardhatGameland = await Gameland.deploy(hardhatNft.address);
        await hardhatGameland.deployed();
        
        expect(await hardhatGameland.testnft()).to.equal(hardhatNft.address);
    });

    it("Mint a NFT, give it to owner", async function () {
      
    await hardhatNft.mint(owner.address,1);
    expect(await hardhatNft.balanceOf(owner.address)).to.equal(1);
    expect(await hardhatNft.ownerOf(1)).to.equal(owner.address);
      
    
    });

    it("Owner deposit NFT to gameland ", async function () {
      await hardhatNft.approve(hardhatGameland.address,1);
      expect(await hardhatNft.getApproved(1)).to.equal(hardhatGameland.address);
      await hardhatGameland.deposit(1,1,1,1);
      expect(await hardhatGameland.nft_owner(1)).to.equal(owner.address); 
      expect(await hardhatNft.ownerOf(1)).to.equal(hardhatGameland.address);
      
    });

    it("Owner withdraw NFT ", async function () {
      await hardhatGameland.withdrawnft(1);
      expect(await hardhatNft.ownerOf(1)).to.equal(owner.address);
    });

    it("Owner deposit NFT and other rent it ", async function () {

      await hardhatNft.approve(hardhatGameland.address,1);
      expect(await hardhatNft.getApproved(1)).to.equal(hardhatGameland.address);
      //let owner_cur_balance = await provider.getBalance(owner.address);

      await hardhatGameland.deposit(1,1,1,1);
      expect(await hardhatGameland.nft_owner(1)).to.equal(owner.address); 
      expect(await hardhatNft.ownerOf(1)).to.equal(hardhatGameland.address);

      await hardhatGameland.connect(borrower).rent(1, {value: ethers.utils.parseEther("2")});
      let borrow_status=await hardhatGameland.borrow_status(1);
      expect(borrow_status[0]).to.equal(borrower.address);

    });

    it("Borrower repay NFT and get collatoral back ", async function () {
      await hardhatNft.connect(borrower).approve(hardhatGameland.address,1);
      await hardhatGameland.connect(borrower).repay(1);
      //expect(await hardhatGameland.nft_owner(1)).to.equal(hardhatGameland.address); 
      expect(await hardhatNft.ownerOf(1)).to.equal(hardhatGameland.address);

    });

    it("Liqudation ready", async function () {
      await hardhatNft.mint(owner.address,2);
      await hardhatNft.approve(hardhatGameland.address,2);
      await hardhatGameland.deposit(1,1,2,1);
      await hardhatGameland.connect(borrower).rent(2, {value: ethers.utils.parseEther("2")});
    });

    it("Liqudation test", async function () {
      await hardhatGameland.liquidation(2);
      expect(await hardhatGameland.nft_owner(2)).to.equal(borrower.address);
    });

    

});