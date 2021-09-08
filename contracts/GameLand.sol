//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract GameLand is ERC721Holder {
    address public testnft;

    constructor(address _nftaddress) {
        testnft = _nftaddress;
    }

    struct Nft {
        uint256 price_per_day;
        uint256 duration;
        uint256 collatoral;
        uint256 totalprice;
    }

    struct borrowInfo {
        address borrower;
        uint256 repay_time;
    }

    //NFT => (borrower ,repay_time)
    mapping(uint256 => borrowInfo) public borrow_status;

    //NFT => basci_info
    mapping(uint256 => Nft) public nft_basic_status;

    // nft => address, origin owner
    mapping(uint256 => address) public nft_owner;

    //record a NFT is borrowed or not
    mapping(uint256 => bool) public borrow_or_not;

    event Received(address from, address to, uint256 nft_id);

    event Withdrawed(address from, address to, uint256 nft_id);

    event Rented(address from, address to, uint256 nft_id);

    event Liquidation(address caller, uint256 nft_id);

    //NFT owner transfer ownership to Origin, set price, duration, collatoral, represent in eth;
    //need approve
    function deposit(
        uint256 pricePerDay,
        uint256 duration,
        uint256 nft_id,
        uint256 collatoral
    ) public {
        //this function will check everything
        (bool success, ) = testnft.call(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                msg.sender,
                address(this),
                nft_id
            )
        );
        require(success);
        uint256 totalprice = pricePerDay * duration + collatoral;
        nft_basic_status[nft_id] = Nft(
            pricePerDay,
            duration,
            collatoral,
            totalprice
        );
        nft_owner[nft_id] = msg.sender;
        borrow_or_not[nft_id] = false;
        emit Received(msg.sender, address(this), nft_id);
    }

    //owner withdraw nft when nft is not borrowing
    function withdrawnft(uint256 nft_id) public {
        require(!borrow_or_not[nft_id], "The nft alrady been borrowed");
        require(msg.sender == nft_owner[nft_id], "Only owner can withdraw NFT");
        (bool success, ) = testnft.call(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                address(this),
                msg.sender,
                nft_id
            )
        );
        require(success);
        delete nft_basic_status[nft_id];
        delete nft_owner[nft_id];
        delete borrow_or_not[nft_id];
        emit Withdrawed(address(this), msg.sender, nft_id);
    }

    // borrower rent,this function will transfer rent to owner
    function rent(uint256 nft_id) public payable {
        require(
            nft_basic_status[nft_id].totalprice <= msg.value,
            "Not enough money"
        );
        require(!borrow_or_not[nft_id], "Already been borrowed out");
        (bool success, ) = testnft.call(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                address(this),
                msg.sender,
                nft_id
            )
        );
        require(success);
        uint256 price = nft_basic_status[nft_id].price_per_day *
            nft_basic_status[nft_id].duration;

        (bool rent_success, ) = nft_owner[nft_id].call{
            value: price - (price * 3) / 100
        }("");
        require(rent_success);

        uint256 duration = nft_basic_status[nft_id].duration;
        borrow_or_not[nft_id] = true;
        borrow_status[nft_id] = borrowInfo(
            msg.sender,
            duration + block.timestamp
        );
        emit Rented(address(this), msg.sender, nft_id);
    }

    // borrower repay nft
    //need approve
    function repay(uint256 nft_id) public {
        require(borrow_or_not[nft_id], "the nft has not been borrowed");
        (bool success, ) = testnft.call(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                msg.sender,
                address(this),
                nft_id
            )
        );
        require(success);

        (bool collatoral_success, ) = borrow_status[nft_id].borrower.call{
            value: nft_basic_status[nft_id].collatoral
        }("");
        require(collatoral_success);

        delete borrow_status[nft_id];
        delete borrow_or_not[nft_id];

        emit Received(msg.sender, address(this), nft_id);
    }

    //owner take collatoral when aggrement broken
    function liquidation(uint256 nft_id) public {
        require(borrow_or_not[nft_id], "the nft has not been borrowed");
        require(msg.sender == nft_owner[nft_id], "Only owner can liquidation");
        require(borrow_status[nft_id].repay_time <= block.timestamp, "Not yet");
        (bool success, ) = nft_owner[nft_id].call{
            value: nft_basic_status[nft_id].collatoral
        }("");
        require(success);
        nft_owner[nft_id] = borrow_status[nft_id].borrower;
        delete borrow_status[nft_id];
        delete borrow_or_not[nft_id];
        emit Liquidation(msg.sender, nft_id);
    }

    //added by ting
    function get_testnft() public view returns (address) {
        return testnft;
    }

    //added by ting
    function get_all_nftinfo(uint256 id)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            nft_basic_status[id].price_per_day,
            nft_basic_status[id].duration,
            nft_basic_status[id].collatoral,
            nft_basic_status[id].totalprice
        );
    }

    //Get the borrower, repay_time, added by ting
    function get_borrow_info(uint256 nft_id) public view returns (address, uint256) {
        return (
            borrow_status[nft_id].borrower,
            borrow_status[nft_id].repay_time
        );
    }

    //Check a NFT is borrowed or not, added by ting
    function check_the_borrow_status(uint256 nft_id) public view returns (bool) {
        return borrow_or_not[nft_id];
    }
    
    //Query the owner of a NFT, added by ting
    function query_the_nft_owner(uint256 nft_id) public view returns (address) {
        return nft_owner[nft_id];
    }
}
