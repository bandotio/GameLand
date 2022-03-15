//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

// /Users/leo/Blockchain/near-hackathon/GameLand/artifacts/contracts/GameLand.sol/GameLand.json
contract GameLand is ERC721Holder, ERC1155Holder {
    //all nft programes
    address[] public nftprogrames;
    address public owner;
    address public rev;

    constructor(address _rev) {
        owner = msg.sender;
        rev = _rev;
    }

    struct Nft {
        //price in ether
        uint256 daily_price;
        uint256 duration;
        uint256 collatoral;
        uint256 total_amount;
    }

    struct borrowInfo {
        address borrower;
        uint256 due_date;
    }

    //NFT => (borrower, due_date)
    mapping(uint256 => borrowInfo) public borrow_status;

    //NFT => basci_info
    mapping(uint256 => Nft) public nft_basic_status;

    // nft => address, origin owner
    mapping(uint256 => address) public nft_owner;

    //if a NFT is borrowed or not
    mapping(uint256 => bool) public borrow_or_not;

    //nft_programe address to their position
    mapping(address => uint256) public programe_number;

    event Received(
        address from,
        address to,
        uint256 gameland_nft_id,
        uint256 nft_id,
        address nft_programe_address,
        uint256 daily_price,
        uint256 duration,
        uint256 collatoral,
        uint256 total_amount,
        bool isERC721
    );

    event Withdrew(
        address from,
        address to,
        uint256 gameland_nft_id,
        uint256 lending_id
    );

    event Rented(
        address from,
        address to,
        uint256 gameland_nft_id,
        uint256 nft_id,
        address nft_programe_address,
        uint32 rented_at,
        uint256 lending_id
    );

    event Confiscated(
        address caller,
        uint256 gameland_nft_id,
        uint256 lending_id
    );

    event Returned(
        address from,
        address to,
        uint256 gameland_nft_id,
        uint256 nft_id,
        address nft_programe_address,
        uint256 lending_id
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function collatoralbalance() public view returns (uint256) {
        return address(this).balance;
    }

    function add_nft_program(address nft_programe_address) public onlyOwner {
        nftprogrames.push(nft_programe_address);
        uint256 how_many_nft_programes_has_in_gameland = nftprogrames.length;
        programe_number[nft_programe_address] =
            how_many_nft_programes_has_in_gameland -
            1;
    }

    function is721(address _nft) public view returns (bool) {
        return IERC165(_nft).supportsInterface(type(IERC721).interfaceId);
    }

    function is1155(address _nft) public view returns (bool) {
        return IERC165(_nft).supportsInterface(type(IERC1155).interfaceId);
    }

    function build_call(
        address nft_programe_address,
        address sender,
        address receiver,
        uint256 nft_id
    ) public view returns (bytes memory callload) {
        if (is721(nft_programe_address)) {
            callload = abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                sender,
                receiver,
                nft_id
            );
        }
        if (is1155(nft_programe_address)) {
            bytes memory empty = "";
            callload = abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256,uint256,bytes)",
                sender,
                receiver,
                nft_id,
                1,
                empty
            );
        }
    }

    //NFT owner transfer the ownership to Gameland, set price, duration, collatoral in eth
    //need approval
    function deposit(
        uint256 daily_price,
        uint256 duration,
        //NFT contract id
        uint256 nft_id,
        uint256 collatoral,
        address nft_programe_address,
        // front-end calculation，gameland_nft_id = uint(string(programe_index)+string(nft_id)),program_index=programe_number[nft_programe_address]
        uint256 gameland_nft_id
    ) public {
        //this function will check everything about nft
        bool success;
        bytes memory calls = build_call(
            nft_programe_address,
            msg.sender,
            address(this),
            nft_id
        );
        (success, ) = nft_programe_address.call(calls);
        require(success);
        uint256 total_amount = daily_price * duration + collatoral;
        nft_basic_status[gameland_nft_id] = Nft(
            daily_price,
            duration,
            collatoral,
            total_amount
        );
        nft_owner[gameland_nft_id] = msg.sender;
        borrow_or_not[gameland_nft_id] = false;
        emit Received(
            msg.sender,
            address(this),
            gameland_nft_id,
            nft_id,
            nft_programe_address,
            daily_price,
            duration,
            collatoral,
            total_amount,
            is721(nft_programe_address)
        );
    }

    //owner withdraw the nft when it is not borrowed
    function withdrawnft(
        uint256 nft_id,
        address nft_programe_address,
        uint256 gameland_nft_id,
        uint256 lending_id
    ) public {
        require(!borrow_or_not[gameland_nft_id], "The nft is borrowed");
        require(
            msg.sender == nft_owner[gameland_nft_id],
            "Only owner can withdraw NFT"
        );
        bool success;
        bytes memory calls = build_call(
            nft_programe_address,
            address(this),
            msg.sender,
            nft_id
        );
        (success, ) = nft_programe_address.call(calls);
        require(success);
        delete nft_basic_status[gameland_nft_id];
        delete nft_owner[gameland_nft_id];
        delete borrow_or_not[gameland_nft_id];
        emit Withdrew(address(this), msg.sender, gameland_nft_id, lending_id);
    }

    // this function will transfer the rent to the owner
    function rent(
        uint256 nft_id,
        address nft_programe_address,
        uint256 gameland_nft_id,
        uint256 lending_id
    ) public payable {
        require(
            nft_basic_status[gameland_nft_id].total_amount <= msg.value,
            "Not enough amount"
        );
        require(!borrow_or_not[gameland_nft_id], "Already been borrowed");
        bool success;
        bytes memory calls = build_call(
            nft_programe_address,
            address(this),
            msg.sender,
            nft_id
        );
        (success, ) = nft_programe_address.call(calls);
        require(success);
        uint256 price = nft_basic_status[gameland_nft_id].daily_price *
            nft_basic_status[gameland_nft_id].duration;
        uint256 fee = (price * 3) / 100;
        uint256 pay_to_owner = price - fee;
        uint32 rented_at = uint32(block.timestamp);
        (bool pay_fee_success, ) = rev.call{value: fee}("");
        require(pay_fee_success);
        (bool rent_success, ) = nft_owner[gameland_nft_id].call{
            value: pay_to_owner
        }("");
        require(rent_success);

        uint256 duration = nft_basic_status[gameland_nft_id].duration;
        borrow_or_not[gameland_nft_id] = true;
        //fixed duration time
        borrow_status[gameland_nft_id] = borrowInfo(
            msg.sender,
            duration * 1 days + rented_at
        );
        uint256 nftId = nft_id;
        address nftAddress = nft_programe_address;
        uint256 lendingId = lending_id;
        uint256 gamelandId = gameland_nft_id;

        emit Rented(
            address(this),
            msg.sender,
            gamelandId,
            nftId,
            nftAddress,
            rented_at,
            lendingId
        );
    }

    // borrower return the nft
    //need approval
    function returnnft(
        uint256 nft_id,
        address nft_programe_address,
        uint256 gameland_nft_id,
        uint256 lending_id
    ) public {
        bool success;
        require(
            borrow_or_not[gameland_nft_id],
            "the nft has not been borrowed"
        );
        bytes memory calls = build_call(
            nft_programe_address,
            msg.sender,
            address(this),
            nft_id
        );
        (success, ) = nft_programe_address.call(calls);
        require(success, "return failed");

        (bool collatoral_success, ) = borrow_status[gameland_nft_id]
            .borrower
            .call{value: nft_basic_status[gameland_nft_id].collatoral}("");
        require(collatoral_success);

        delete borrow_status[gameland_nft_id];
        delete borrow_or_not[gameland_nft_id];

        uint256 lendingId = lending_id;
        
        emit Returned(
            msg.sender,
            address(this),
            gameland_nft_id,
            nft_id,
            nft_programe_address,
            lendingId
        );
    }

    //owner take the collatoral when the borrower failed to return the nft
    function confiscation(uint256 gameland_nft_id, uint256 lending_id) public {
        require(
            borrow_or_not[gameland_nft_id],
            "the nft has not been borrowed"
        );
        require(
            msg.sender == nft_owner[gameland_nft_id],
            "Only owner can confiscate"
        );
        require(
            borrow_status[gameland_nft_id].due_date <= block.timestamp,
            "Not yet"
        );
        (bool success, ) = nft_owner[gameland_nft_id].call{
            value: nft_basic_status[gameland_nft_id].collatoral
        }("");
        require(success);
        nft_owner[gameland_nft_id] = borrow_status[gameland_nft_id].borrower;
        delete borrow_status[gameland_nft_id];
        delete borrow_or_not[gameland_nft_id];
        emit Confiscated(msg.sender, gameland_nft_id, lending_id);
    }

    function get_nft_programes() public view returns (address[] memory) {
        return nftprogrames;
    }
}
