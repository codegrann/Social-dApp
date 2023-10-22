# Immutable Passport Integration Guide

## Introduction

Passport is a blockchain-based identity and wallet system designed for Web3 games. It offers users a persistent identity that remains consistent across various Web3 applications. Passport includes a non-custodial wallet by default, ensuring a user-friendly transaction experience comparable to traditional web2 standards.

## Setup

This section provides a step-by-step guide on how to integrate Passport authentication into your application.

### Register Your Application

Before using Passport, you must register your application as an OAuth 2.0 client in the Immutable Developer Hub. Follow these steps:

1. Create a project and a testnet environment.
2. Navigate to the Passport configuration screen and create a Passport client for your environment.
3. When you're ready to launch your application on the mainnet, configure a Passport client under a mainnet environment.

Register your application as an OAuth 2.0 client in the Immutable Developer Hub by clicking the "Add Client" button on the Passport page.

#### Things to Note When Adding a Client

When adding a client, ensure you provide the following details:

i) Application Type: The type of your application. Currently, only the Web Application option is available.

ii) Client Name: The name used to identify your application.

iii) Logout URLs: The URL where users will be redirected upon logging out of your application.

iv) Callback URLs: The URL where users will be redirected after the authentication is complete and where your application processes the authentication response.

v) Web origin URLs: The URLs allowed to request authorization (available for the Native application type).

Once your application is successfully registered, make a note of your application's Client ID, Callback URL, and Logout URL for later use in initializing the Passport module in your application.

### Install and Initialize

Before you can use Passport, you need to install the Immutable SDK and initialize the Passport Client.

**Prerequisites:**

- An application registered in the Immutable Developer Hub.
- Node.js version 18 or higher.

#### 1. Install

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

#### 2. Initialize Passport

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

#### 3. Next Steps

You have now successfully installed and initialized the Passport module. The next step is to enable users' identity via a user's Passport account in your application.

### Enable User Identity

Immutable Passport is an Open ID provider and uses the Open ID Connect protocol for authentication and authorization. Third-party applications, such as games or marketplaces, can integrate Passport into their platforms to authenticate their users and access their wallets.

#### How Authentication Works

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

### Log In Users

This section guides you through enabling users to log into your application using their Passport accounts. Users are required to log in before your application can interact with their wallets or call any user-specific functionality.

**Prerequisites:**

- Have the Passport module installed and initialized.

#### 1. Initialize the Provider

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

#### 2. Trigger the Login Process
