## Root Finder

A simple implementation of a root finding algorithm RMM-01 using the Newton-Raphson method. This was done to test out the [Solstat](https://github.com/primitivefinance/solstat) library.

Modern CFMMs like RMM-01 implement more complicated trading functions that have variables that dynamically change such as volatility and time to expiry.

Since RMM-01 is a non-linear function that must equal 0. We can quickly solve for liquidity `L`, the denominator that normalizes the reserves to ensure F(L) = 0. 

A more through explanation of how Newton's method works can be found in my [tweet](https://x.com/robertleifke/status/1849938696134590804).

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/deployRootFinder.s.sol:DeployRootFinder --rpc-url <YOUR_RPC_URL> --broadcast --private-key $PRIVATE_KEY
```

### Cast

```shell
$ cast <subcommand>
```
