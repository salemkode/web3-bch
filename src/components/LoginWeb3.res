type web3
type providerRequest = {method: string}
type provider = {request: (. providerRequest) => Promise.t<string>}
type web3auth = {
  initModal: (. unit) => Promise.t<unit>,
  connect: (. unit) => Promise.t<provider>,
}
type chainConfig = {
  chainNamespace: string,
  chainId: string,
  rpcTarget: string,
  displayName: string,
  blockExplorer: string,
  ticker: string,
  tickerName: string,
}
type web3AuthConfig = {
  clientId: string, // get from https://dashboard.web3auth.io
  chainConfig: chainConfig,
}
@module("@web3auth/web3auth") @new external web3Auth: web3AuthConfig => web3auth = "Web3Auth"
@module @new external web3: provider => web3 = "web3"

let web3Auth = web3Auth({
  clientId: "BNJ1SzF-YpyUMydzFB8O0-7GZLcQUoNUNJpbP5CdtHNOst1Q4_wIxJYetNgyuq7kIaXGpMOf8gEtZIdf6lpXiwU", // get from https://dashboard.web3auth.io
  chainConfig: {
    chainNamespace: "other",
    chainId: "0x1",
    rpcTarget: "https://rpc.ankr.com/eth",
    // Avoid using public rpcTarget in production.
    // Use services like Infura, Quicknode etc
    displayName: "Ethereum Mainnet",
    blockExplorer: "https://etherscan.io/",
    ticker: "ETH",
    tickerName: "Ethereum",
  },
})

type providerState =
  | Provide(provider)
  | None
type web3Key =
  | PrivateKey(string)
  | Empty

@react.component
let make = () => {
  let (provider, setProvider) = React.useState(_ => None)
  let (web3Key, setWeb3Key) = React.useState(_ => Empty)

  //
  let connect = _ => {
    web3Auth.initModal(.)
    ->Promise.then(() => {
      web3Auth.connect(.)
      ->Promise.then(provide => {
        setProvider(_ => Provide(provide))
        Js.log(provide)

        Promise.resolve()
      })
      ->ignore

      Promise.resolve()
    })
    ->ignore
  }

  //
  let getPrivetKey = _ => {
    Js.log(provider)
    switch provider {
    | Provide(web3Provider) => web3Provider.request(. {
        method: "private_key",
      })
    | None => Promise.resolve("")
    }
    ->Promise.then(address => {
      setWeb3Key(_ => PrivateKey(address))
      Promise.resolve()
    })
    ->Promise.catch(error => raise(error))
    ->ignore
  }

  //
  let conent = switch provider {
  | Provide(_) =>
    <>
      <h2 className="m-2 p-2"> {React.string("Connected on web3-auth")} </h2>
      <div className="d-flex">
        <button
          className="btn btn-primary m-2 d-block"
          disabled={provider == None}
          onClick={getPrivetKey}>
          {React.string("Get key of web3 wallet -")}
        </button>
        <span>
          {switch web3Key {
          | PrivateKey(key) => "Ower key: " ++ key
          | Empty => "expression"
          }->React.string}
        </span>
      </div>
    </>
  | None => <h2 className="m-2 p-2"> {React.string("Not connect")} </h2>
  }

  <div>
    <button className="btn btn-primary m-2 d-block" onClick={connect}>
      {React.string("Connect in web3auth")}
    </button>
    {conent}
  </div>
}
