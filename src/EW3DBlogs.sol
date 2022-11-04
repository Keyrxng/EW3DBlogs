// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EW3DBlogs is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Strings for uint8;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => BlogPost) public idToPost;
    mapping(uint256 => string) public idToImg;
    mapping(uint256 => address) public idToOwner;

    struct BlogPost {
        string title;
        string desc;
        string content;
        string img;
        string tags;
        uint256 date;
    }

    BlogPost[] public blogPosts;

    modifier isOwner(uint256 _tokenId) {
        require(msg.sender == idToOwner[_tokenId]);
        _;
    }

    constructor() ERC721("EW3DBlogs", "EW3DB") {}

    function grabInfo(uint256 _tokenId) public view returns (string memory) {
        bytes memory infos = abi.encodePacked(
            '<text x="50%" y="10%" class="base" dominant-baseline="middle" text-anchor="middle">',
            getTitle(_tokenId),
            "</text>",
            '<text x="50%" y="15%" class="base" dominant-baseline="middle" text-anchor="middle">',
            getDesc(_tokenId),
            "</text>",
            '<foreignObject x="20" y="70" width="95%" height="100%" color="white" font-family="arial" dominant-baseline="middle" text-anchor="middle">',
            '<body xmlns="http://www.w3.org/1999/xhtml"  >',
            getContent(_tokenId),
            "</body>",
            "</foreignObject>"
        );
        return string(infos);
    }

    function generatePost(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350" overflow="auto">',
            "<style>.base { fill: white; font-family: arial; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            grabInfo(_tokenId),
            "</svg>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenUri(uint256 _tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Blog Post #',
            _tokenId.toString(),
            '",',
            '"description": "',
            getDesc(_tokenId),
            '",',
            '"image": "',
            generatePost(_tokenId),
            '",',
            '"img": "',
            getImg(_tokenId),
            '",',
            '"tags": "',
            getTags(_tokenId),
            '"',
            "}"
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint(
        string calldata _title,
        string calldata _description,
        string calldata _content,
        string calldata _img,
        string calldata _tags
    ) public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        BlogPost memory post = BlogPost(
            _title,
            _description,
            _content,
            _img,
            _tags,
            block.timestamp
        );
        blogPosts.push(post);
        idToPost[newItemId] = post;
        idToImg[newItemId] = _img;
        idToOwner[newItemId] = msg.sender;
        _setTokenURI(newItemId, getTokenUri(newItemId));
    }

    function getBlogsLen() public view returns (uint256) {
        return _tokenIds.current();
    }

    function getTitle(uint256 _tokenId) public view returns (string memory) {
        BlogPost memory post = idToPost[_tokenId];
        return post.title;
    }

    function getDesc(uint256 _tokenId) public view returns (string memory) {
        BlogPost memory post = idToPost[_tokenId];
        return post.desc;
    }

    function getDate(uint256 _tokenId) public view returns (uint256) {
        BlogPost memory post = idToPost[_tokenId];
        return post.date;
    }

    function getContent(uint256 _tokenId) public view returns (string memory) {
        BlogPost memory post = idToPost[_tokenId];
        return post.content;
    }

    function getTags(uint256 _tokenId) public view returns (string memory) {
        BlogPost memory post = idToPost[_tokenId];
        return post.tags;
    }

    function getImg(uint256 _tokenId) public view returns (string memory) {
        return idToImg[_tokenId];
    }

    function getOwner(uint256 _tokenId) public view returns (address) {
        return idToOwner[_tokenId];
    }

    function updatePostTitle(uint256 _tokenId, string calldata _title)
        public
        isOwner(_tokenId)
    {
        require(_exists(_tokenId), "ID doesn't exist");
        require(ownerOf(_tokenId) == msg.sender, "non-ownership");
        BlogPost storage post = idToPost[_tokenId];
        delete post.title;
        post.title = _title;
        idToPost[_tokenId] = post;

        _setTokenURI(_tokenId, getTokenUri(_tokenId));
    }

    function updatePostDesc(uint256 _tokenId, string calldata _desc)
        public
        isOwner(_tokenId)
    {
        require(_exists(_tokenId), "ID doesn't exist");
        require(ownerOf(_tokenId) == msg.sender, "non-ownership");
        BlogPost storage post = idToPost[_tokenId];
        delete post.desc;
        post.desc = _desc;
        idToPost[_tokenId] = post;

        _setTokenURI(_tokenId, getTokenUri(_tokenId));
    }

    function updatePostContent(uint256 _tokenId, string calldata _content)
        public
        isOwner(_tokenId)
    {
        require(_exists(_tokenId), "ID doesn't exist");
        require(ownerOf(_tokenId) == msg.sender, "non-ownership");
        BlogPost storage post = idToPost[_tokenId];
        delete post.content;
        post.content = _content;
        idToPost[_tokenId] = post;

        _setTokenURI(_tokenId, getTokenUri(_tokenId));
    }

    function updatePostTags(uint256 _tokenId, string calldata _tags)
        public
        isOwner(_tokenId)
    {
        require(_exists(_tokenId), "ID doesn't exist");
        require(ownerOf(_tokenId) == msg.sender, "non-ownership");
        BlogPost storage post = idToPost[_tokenId];
        delete post.tags;
        post.tags = _tags;
        idToPost[_tokenId] = post;

        _setTokenURI(_tokenId, getTokenUri(_tokenId));
    }

    function updateImg(uint256 _tokenId, string calldata _img)
        public
        isOwner(_tokenId)
    {
        require(_exists(_tokenId), "ID doesn't exist");
        require(ownerOf(_tokenId) == msg.sender, "non-ownership");
        BlogPost storage post = idToPost[_tokenId];
        delete post.img;
        post.img = _img;

        idToImg[_tokenId] = _img;
        _setTokenURI(_tokenId, getTokenUri(_tokenId));
    }
}
