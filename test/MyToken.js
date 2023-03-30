const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { bytecode } = require("../artifacts/contracts/MyToken.yul/MyToken.json");


describe("MyToken", function () {

    const name = "MyToken";
    const symbol = "MTK";
    const decimals = 18;

    async function deploy() {
        [owner, user1, user2] = await ethers.getSigners();

        const MyTokenFactory = await ethers.getContractFactory("MyTokenFactory");
        const myTokenFactory = await MyTokenFactory.deploy(bytecode);
        await myTokenFactory.deployed();
    
        const txCreate = await myTokenFactory.createToken2(owner.address, name, symbol, decimals);
        await txCreate.wait();
    
        const tokenAddress = await myTokenFactory.tokenAddress();
    
        const token = await ethers.getContractAt("IERC20", tokenAddress, owner);
    
        return { owner, user1, user2, token };
    }

    it("Should deploy", async function () {
        const { token } = await loadFixture(deploy);
        expect(token.address).to.be.properAddress;
    });

    describe("Meta", function () {
        let token;
        let owner;

        beforeEach(async () => {
            const { token: _token, owner: _owner } = await loadFixture(deploy);
            token = _token;
            owner = _owner;
        });

        it('has an owner', async () => {
            expect(await token.owner()).to.equal(owner.address);
        });

        it('has a name', async () => {
            expect(await token.name()).to.equal(name);
        });
    
        it('has a symbol', async () => {
            expect(await token.symbol()).to.equal(symbol);
        });

        it('has 18 decimals', async function () {
            expect(await token.decimals()).to.be.equal(decimals);
        });
    });

    describe("Mint", () => {
        let token, owner, user1;

        beforeEach(async () => {
            const { owner: _owner, user1: _user1, token: _token } = await loadFixture(deploy);
            token = _token;
            owner = _owner;
            user1 = _user1;
        });

        it("Should mint if an owner", async () => {
            await token.connect(owner).mint(user1.address, 100);
            expect(await token.balanceOf(user1.address)).to.equal(100);
        });

        it("Should not mint if not owner", async () => {
            await expect(token.connect(user1).mint(user1.address, 100)).to.be.revertedWith("MTK: mint as not an owner");
        });

        it("Should not mint to zero address", async () => {
            await expect(token.connect(owner).mint(ethers.constants.AddressZero, 100)).to.be.revertedWith("ERC20: mint to the zero address");
        })
    });

    describe("Operations", () => {
        let token, owner, user1;

        beforeEach(async () => {
            const { owner: _owner, user1: _user1, token: _token } = await loadFixture(deploy);
            token = _token;
            owner = _owner;
            user1 = _user1;

            await token.connect(owner).mint(user1.address, 100);
        });

        describe("Burn", () => {

            it("Should burn proper amount", async () => {
                await token.connect(user1).burn(25);
                expect(await token.balanceOf(user1.address)).to.equal(75);
            });
    
            it("Should not burn when amount exceeds balance", async () => {
                await expect(token.connect(user1).burn(101)).to.be.revertedWith("ERC20: burn amount exceeds balance");
            });
        });
    
        describe("Allowance", () => {

            it("Should approve", async () => {
                await token.connect(user1).approve(owner.address, 25);
                expect(await token.allowance(user1.address, owner.address)).to.equal(25);
            });
    
            it("Should not approve to zero address", async () => {
                await expect(token.connect(user1).approve(ethers.constants.AddressZero, 25)).to.be.revertedWith("ERC20: approve to the zero address");
            });
    
            it("Should increase allowance", async () => {
                await token.connect(user1).approve(owner.address, 50);
                await token.connect(user1).increaseAllowance(owner.address, 25);
                expect(await token.allowance(user1.address, owner.address)).to.equal(75);
            });
    
            it("Should decrease allowance", async () => {
                await token.connect(user1).approve(owner.address, 75);
                await token.connect(user1).decreaseAllowance(owner.address, 25);
                expect(await token.allowance(user1.address, owner.address)).to.equal(50);
            });
    
            it("Should not decrease allowance when amount exceeds allowance", async () => {
                await token.connect(user1).approve(owner.address, 100);
                await expect(token.connect(user1).decreaseAllowance(owner.address, 101)).to.be.revertedWith("ERC20: decreased allowance below zero");
            });
        });
    
        describe("Transfer", () => {

            it("Should transfer", async () => {
                await token.connect(user1).transfer(owner.address, 25);
                expect(await token.balanceOf(user1.address)).to.equal(75);
                expect(await token.balanceOf(owner.address)).to.equal(25);
            });
    
            it("Should not transfer to zero address", async () => {
                await expect(token.connect(user1).transfer(ethers.constants.AddressZero, 25)).to.be.revertedWith("ERC20: transfer to the zero address");
            });
    
            it("Should not transfer when amount exceeds balance", async () => {
                await expect(token.connect(user1).transfer(owner.address, 101)).to.be.revertedWith("ERC20: transfer amount exceeds balance");
            });
    
            it("Should transfer proper amount", async () => {
                await token.connect(user1).transfer(owner.address, 25);
                await token.connect(user1).transfer(owner.address, 50);
                expect(await token.balanceOf(user1.address)).to.equal(25);
                expect(await token.balanceOf(owner.address)).to.equal(75);
            });
        });
    
        describe("BurnFrom", () => {
            
            it("Should burn and spend allowance", async () => {
                await token.connect(user1).approve(owner.address, 70);
                await token.connect(owner).burnFrom(user1.address, 25);
                expect(await token.balanceOf(user1.address)).to.equal(75);
                expect(await token.allowance(user1.address, owner.address)).to.equal(45);
            });
    
            it("Should not spend when allowance is max", async () => {
                await token.connect(user1).approve(owner.address, ethers.constants.MaxUint256);
                await token.connect(owner).burnFrom(user1.address, 75);
                expect(await token.allowance(user1.address, owner.address)).to.equal(ethers.constants.MaxUint256);
            });
    
            it("Should not burn when amount exceeds balance", async () => {
                await token.connect(user1).approve(owner.address, 101);
                await expect(token.connect(owner).burnFrom(user1.address, 101)).to.be.revertedWith("ERC20: burn amount exceeds balance");
            });
    
            it("Should not burn when amount exceeds allowance", async () => {
                await token.connect(user1).approve(owner.address, 25);
                await expect(token.connect(owner).burnFrom(user1.address, 26)).to.be.revertedWith("ERC20: insufficient allowance");
            });
        });
    
        describe("TransferFrom", () => {
            
            it("Should approve and transfer", async () => {
                await token.connect(user1).approve(owner.address, 75);
                expect(await token.allowance(user1.address, owner.address)).to.equal(75);
                await token.connect(owner).transferFrom(user1.address, owner.address, 75);
                expect(await token.balanceOf(user1.address)).to.equal(25);
                expect(await token.balanceOf(owner.address)).to.equal(75);
                expect(await token.allowance(user1.address, owner.address)).to.equal(0);
            });
    
            it("Should not transfer when allowance is zero", async () => {
                await expect(token.connect(owner).transferFrom(user1.address, owner.address, 25)).to.be.revertedWith("ERC20: insufficient allowance");
            });
    
            it("Should not transfer to zero address", async () => {
                await token.connect(user1).approve(owner.address, 25);
                await expect(token.connect(owner).transferFrom(user1.address, ethers.constants.AddressZero, 25)).to.be.revertedWith("ERC20: transfer to the zero address");
            });
    
            it("Should not transfer when allowance exceeds", async () => {
                await token.connect(user1).approve(owner.address, 50);
                await expect(token.connect(owner).transferFrom(user1.address, owner.address, 51)).to.be.revertedWith("ERC20: insufficient allowance");
            });
    
            it("Should not transfer when balance exceeds", async () => {
                await token.connect(user1).approve(owner.address, 100);
                await expect(token.connect(owner).transferFrom(user1.address, owner.address, 101)).to.be.revertedWith("ERC20: insufficient allowance");
            });
    
            it("Should spend allowance after transfer", async () => {
                await token.connect(user1).approve(owner.address, 75);
                await token.connect(owner).transferFrom(user1.address, owner.address, 25);
                expect(await token.allowance(user1.address, owner.address)).to.equal(50);
            });
    
            it("Should not spend when allowance is max", async () => {
                await token.connect(user1).approve(owner.address, ethers.constants.MaxUint256);
                await token.connect(owner).transferFrom(user1.address, owner.address, 100);
                expect(await token.allowance(user1.address, owner.address)).to.equal(ethers.constants.MaxUint256);
            });
        });
    });
});
