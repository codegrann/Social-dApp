# Immutable Passport Integration Guide

## Table of Contents

1. [Introduction](#1-introduction)
2. [Setup](#2-setup)
   - 2.1 [Register Your Application](#21-register-your-application)
   - 2.2 [Install and Initialize](#22-install-and-initialize)
3. [Enable User Identity](#3-enable-user-identity)
   - 3.1 [How Authentication Works](#31-how-authentication-works)
4. [Log In Users](#4-log-in-users)
   - 4.1 [Initialize the Provider](#41-initialize-the-provider)
   - 4.2 [Trigger the Login Process](#42-trigger-the-login-process)
   - 4.3 [Configure the Login Callback](#43-configure-the-login-callback)
5. [Log Out Users](#5-log-out-users)
   - 5.1 [How to Log Out a User](#51-how-to-log-out-a-user)
   - 5.2 [Logout Modes](#52-logout-modes)
6. [Get User Information](#6-get-user-information)
   - 6.1 [Getting User Information](#61-getting-user-information)
7. [Enable User Wallet Interactions](#7-enable-user-wallet-interactions)
   - 7.1 [Validating a Message Signature](#73-validating-a-message-signature)
8. [Send Your First Transaction](#8-send-your-first-transaction)
   - 8.1 [Scenario](#81-scenario)
   - 8.2 [Create a New Contract Instance](#82-create-a-new-contract-instance)
   - 8.3 [Call the Contract Method](#83-call-the-contract-method)
   - 8.4 [Working with Typescript](#84-working-with-typescript)

## 1. Introduction

Passport is a blockchain-based identity and wallet system designed for Web3 games. It offers users a persistent identity that remains consistent across various Web3 applications. Passport includes a non-custodial wallet by default, ensuring a user-friendly transaction experience comparable to traditional web2 standards.

## 2. Setup

This section provides a step-by-step guide on how to integrate Passport authentication into your application.

### 2.1 Register Your Application

Before using Passport, you must register your application as an OAuth 2.0 client in the Immutable Developer Hub. Follow these steps:

1. Create a project and a testnet environment.
2. Navigate to the Passport configuration screen and create a Passport client for your environment.
3. When you're ready to launch your application on the mainnet, configure a Passport client under a mainnet environment.

Register your application as an OAuth 2.0 client in the Immutable Developer Hub by clicking the "Add Client" button on the Passport page. More information can be found [here](https://docs.immutable.com/docs/zkEVM/products/passport/register-application)

#### Things to Note When Adding a Client

When adding a client, ensure you provide the following details:

i) Application Type: The type of your application. Currently, only the Web Application option is available.

ii) Client Name: The name used to identify your application.

iii) Logout URLs: The URL where users will be redirected upon logging out of your application.

iv) Callback URLs: The URL where users will be redirected after the authentication is complete and where your application processes the authentication response.

v) Web origin URLs: The URLs allowed to request authorization (available for the Native application type).

Once your application is successfully registered, make a note of your application's Client ID, Callback URL, and Logout URL for later use in initializing the Passport module in your application.

### 2.2 Install and Initialize

Before you can use Passport, you need to install the Immutable SDK and initialize the Passport Client. You can refer to [this article](https://docs.immutable.com/docs/zkEVM/products/passport/install) for a more detailed guidance.

**Prerequisites:**

- An application registered in the Immutable Developer Hub.
- Node.js version 18 or higher.

#### a. Install

To install the Immutable SDK, run the following command in your project's root directory:

```bash
node - npm install -D @imtbl/sdk
```

or

```bash
yarn - yarn add --dev @imtbl/sdk

```

**Troubleshooting:**

If you encounter issues during the installation, use the following commands to ensure the most recent release of the SDK is correctly installed.

For npm:

```bash
node - rm -Rf node_modules
npm cache clean --force
npm i
```

For Yarn

```bash
yarn - rm -Rf node_modules
yarn cache clean
yarn
```

#### b. Initialize Passport

Next, you'll need to initialize the Passport client. The Passport constructor accepts a PassportModuleConfiguration object.

```bash
import { config, passport } from '@imtbl/sdk';

const passportInstance = new passport.Passport({
  baseConfig: new config.ImmutableConfiguration({
    environment: config.Environment.PRODUCTION,
  }),
  clientId: '<YOUR_CLIENT_ID>',
  redirectUri: 'https://example.com',
  logoutRedirectUri: 'https://example.com/logout',
  audience: 'platform_api',
  scope: 'openid offline_access email transact',
});

```

**Note:** The Passport constructor may throw the following error: **INVALID_CONFIGURATION**. This occurs when the environment configuration or OIDC Configuration is incorrect. Verify that you are passing the correct configuration settings.

#### c. Next Steps

You have now successfully installed and initialized the Passport module. The next step is to enable users' identity via a user's Passport account in your application.

## 3. Enable User Identity

Immutable Passport is an Open ID provider and uses the Open ID Connect protocol for authentication and authorization. Third-party applications, such as games or marketplaces, can integrate Passport into their platforms to authenticate their users and access their wallets.

### 3.1 How Authentication Works

When using Passport as an identity provider, the authentication flow begins within your application. If the user already has an account with Passport, they can sign in to their existing account using the same credentials, which can be shared across multiple apps.

For new users, they will need to sign up for a new account and complete the authentication flow to be authenticated in your application.

The high-level steps for the authentication flow are as follows:

. The user clicks on "Login with Passport" in your application.

. A pop-up window opens with Passport's secure login page (auth.immutable.com).

. The user authenticates based on their preferred login method.

. The user approves the scopes you requested when registering your app's OAuth client (only once).

. The user is redirected to the callback URL you defined when registering your app's OAuth client.

. Your application obtains an id_token and an access_token.

If you are using the Immutable SDK, all these steps are simplified by the **provider.requestAccounts()** function.

## 4. Log In Users

This section guides you through enabling users to log into your application using their Passport accounts. Users are required to log in before your application can interact with their wallets or call any user-specific functionality.

**Prerequisites:**

- Have the Passport module installed and initialized.

### 4.1 Initialize the Provider

Passport provider implements the Ethereum EIP-1193 standard, which allows you to interact with a user's Passport wallet as you would with any other Ethereum wallet. You can use Passport's zkEVM provider or integrate it with Ethers.js.

##### Using Passport (EIP-1193)

Create the Passport provider:

```bash
const passportProvider = passport.connectEvm();
```

Once a provider is created, you can call various methods on it via the request function, which is protocol-agnostic.

#### Using Ethers.js

Passport is also compatible with existing Ethereum libraries like Ethers.js. You can create a new provider with Passport.

Example:

```bash
import { ethers } from 'ethers';

const passportProvider = passport.connectEvm();
const provider = new ethers.providers.Web3Provider(passportProvider);

// Use the provider as you would any other Ethereum provider:
const signer = provider.getSigner();
const address = await signer.getAddress();

```

### 4.2 Trigger the Login Process

The login flow is triggered by calling the **_`requestAccounts`_** RPC on the Passport provider. Depending on whether you are using the EIP-1193 provider directly or Ethers.js, you can call the **_requestAccounts_** method.

#### Using Passport (EIP-1193)

If you are using an EIP-1193 provider directly, you can call the requestAccounts method directly:

```bash
const provider = passport.connectEvm();
const accounts = await provider.request({ method: "eth_requestAccounts" });

```

Once the **_requestAccounts_** RPC method has been called, the Passport module will begin the authentication process. If the user successfully authenticates, they will be redirected to the Redirect URI defined in the OIDC Configuration.

#### Using Ethers.js

With Ethers.js, you can use the Passport provider and then call the send method to trigger the login process:

```bash
import { ethers } from 'ethers';

const passportProvider = passport.connectEvm();
const provider = new ethers.providers.Web3Provider(passportProvider);

const accounts = await provider.send("eth_requestAccounts", []);

```

Once the **_requestAccounts_** RPC method has been called, the Passport module will begin the authentication process, and the user will be redirected to the Redirect URI defined in the OIDC Configuration.

### 4.3 Configure the Login Callback

At this point, the route that handles requests to the Redirect URI will need to call the **_loginCallback_** method on page load. Your specific implementation will vary based on your application's architecture, but a vanilla JavaScript implementation may look as follows:

```bash
window.addEventListener('load', function() {
  passport.loginCallback();
});
```

The **_loginCallback_** method will process the response from the Immutable's auth domain, store the authenticated user in session storage, and close the pop-up. Once the authentication flow is complete, the Promise returned from requestAccounts will also resolve with a single-item array containing the user's address.

## 5. Log Out Users

This section instructs you on how to log users out of Passport and your application.

**Prerequisites:**

The user must be logged into your application via Passport.

### 5.1 How to Log Out a User

When a user authenticates through Passport, there are two "sessions" you need to account for:

- The Passport session layer maintains a session between the user and Passport in auth.immutable.com.
- The application session layer maintains a session between the user and your application through JWTs.
  T o log out a user from your application and Passport, you can use the logout function on the Passport instance.

1. Initialize Passport and set the preferred logout mode:

```bash
const passport = new Passport({
  logoutRedirectUri: 'http://localhost:3000',
  logoutMode: 'redirect', // defaults to 'redirect' if not set
  // ...
});

```

2. Authenticate the user. Refer to the "Enable User Login" page for more information.

3. Log the user out:

```bash
await passport.logout();

```

### 5.2 Logout Modes

Redirect Mode: The 'redirect' logout mode clears the application session by removing the JWT from the browser's local storage. The user is then redirected to the Passport auth domain, where the Passport session is cleared. Finally, the user is redirected back to the specified logoutRedirectUri.

## 6. Get User Information

This section instructs you on how to get information about the user currently logged in.

**Prerequisites:**

- The user must be logged into your application via Passport.

### 6.1 Getting User Information

The **_getUserInfo_** function on the Passport instance returns information about the currently logged-in user.

```bash
const userProfile = await passport.getUserInfo();
```

Properties of the user profile include:

- email: The email address of the logged-in user. This property will be undefined if the email scope has not been requested.
- sub: The subject (unique identifier) of the logged-in user.
- nickname: The nickname of the logged-in user.
  Note that the **_getUserInfo_** function may throw the error **_NOT_LOGGED_IN_ERROR_** if no user is logged in at the time of the function call. Verify that a user has logged in before attempting to call **_getUserInfo_**.

## 7. Enable User Wallet Interactions

This section guides you on connecting to users' Passport wallets to facilitate useful game transactions, such as transfers or payments.

A wallet provider allows you to connect to a user's wallet and facilitate blockchain transactions. Immutable makes it easy to initialize a provider for a user's Passport wallet.

**Prerequisites:**

Have the Passport module installed and initialized.
Using Passport (EIP-1193)
Create the Passport provider:

```bash
const passportProvider = passport.connectEvm();
```

Once a provider is created, you can call various methods on it via the request function (protocol-agnostic).

#### Using Ethers.js

Passport is also compatible with existing Ethereum libraries and products, such as Ethers.js.

For example, you may want to use the Passport provider when creating a new provider with Ethers.js, which abstracts the complexity of interacting directly with an EIP-1193 provider:

```bash
import { ethers } from 'ethers';

const passportProvider = passport.connectEvm();
const provider = new ethers.providers.Web3Provider(passportProvider);

// Use the provider as you would any other Ethereum provider:
const signer = provider.getSigner();
const address = await signer.getAddress();
```

### 7.1 Validating a Message Signature

To verify a signature, the user's smart contract wallet must have been deployed previously. When signing a message using the signTypedData Passport method, a unique signature string is returned. Verifying the authenticity of a signature can be done by calling the isSignatureValid method on the smart contract. You can use Ethers.js to achieve this.

Here's an example:

```bash

import { ethers } from 'ethers';

const ERC_1271_MAGIC_VALUE = '0x1626ba7e';

export const isSignatureValid = async (
  address: string,
  payload: TypedDataPayload,
  signature: string,
  zkEvmProvider: Provider,
) => {
  const types = { ...payload.types };
  // Ethers auto-generates the EIP712Domain type in the TypedDataEncoder, and so it needs to be removed
  delete types.EIP712Domain;

  const hash = ethers.utils._TypedDataEncoder.hash(
    payload.domain,
    types,
    payload.message,
  );
  const contract = new ethers.Contract(
    address,
    ['function isValidSignature(bytes32, bytes) public view returns (bytes4)'],
    new ethers.providers.Web3Provider(zkEvmProvider),
  );

  const isValidSignatureHex = await contract.isValidSignature(hash, signature);
  return isValidSignatureHex === ERC_1271_MAGIC_VALUE;
};
```

## 8. Send Your First Transaction

This section guides you through the process of sending a transaction to the zkEVM network with Ethers.js and the Passport zkEVM provider.

**Prerequisites:**

. Have the Passport module installed and initialized.

. Install ethers.js (npm install ethers, using ethers v5).

### 8.1 Scenario

In this scenario, we will send a transaction to the zkEVM network to transfer an ERC-721 token. Ethers provides a helper class called Contract that allows us to interact with smart contracts by abstracting data encoding using the contract ABI.

### 8.2 Create a New Contract Instance

First, create a new instance of the contract you want to interact with. In this example, we will use the ERC-721 interface:

```bash
import { ethers } from 'ethers';

const provider = passport.connectEvm();
const signer = provider.getSigner();

const userAddress = await signer.getAddress();
const toAddress = '<address to transfer the token to>';
const erc721ContractAddress = '<address of the ERC-721 contract>';
const tokenId = 1234;

// Construct the contract interface using the ABI
const contract = new ethers.Contract(
  erc721ContractAddress,
  [
    'function safeTransferFrom(address from, address to, uint256 tokenId)',
  ],
  signer,
);
```

### 8.3 Call the Contract Method

Now, you can call the contract method:

```bash
const tx = await contract.safeTransferFrom(
  userAddress,
  toAddress,
  tokenId,
);

// Wait for the transaction to complete
await tx.wait();
```

Under the hood, ethers will build an **_eth_sendTransaction_** RPC call to the Passport provider, including data, 'to', and 'from' fields.

### 8.4 Working with Typescript

To make the contract interface type-safe, you can use Typechain to generate TypeScript interfaces from the contract ABI. The contract ABI can be stored or exported to a file and then used to generate the TypeScript interfaces.

Example:

```bash
typechain --target=ethers-v5 -out-dir=app/contracts abis/ERC721.json
```

The generated code includes a contract factory that can be used to create a contract instance. Here's an example:

```bash
import { ethers } from 'ethers';
import { ERC721_factory, ERC721 } from './contracts';

const provider = passport.connectEvm();
const signer = provider.getSigner();

const userAddress = await signer.getAddress();
const toAddress = '<address to transfer the token to>';
const erc721ContractAddress =  '<address of the ERC-721 contract>';

// Create a new instance of the contract
const contract: ERC721 = ERC721_factory.connect(
  erc721ContractAddress,
  signer,
);

// Call the contract method, with type-safe arguments
const tx = await contract.safeTransferFrom(
  userAddress,
  toAddress,
  tokenId,
);

```
