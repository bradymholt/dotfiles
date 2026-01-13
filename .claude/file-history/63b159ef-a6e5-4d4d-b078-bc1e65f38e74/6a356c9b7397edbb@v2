# YNAB Recurring Charges Finder

A React web app that uses the YNAB API to find recurring charges to the same payee. This is helpful for:
- Finding and canceling forgotten subscriptions
- Identifying all recurring charges when a credit card needs to be updated due to fraud

## Features

- Secure OAuth authentication with your YNAB account
- Select any of your budgets
- Automatically detect recurring charges based on transaction patterns
- View recurring charges sorted by amount
- See transaction history for each recurring charge
- Mobile-responsive design

## Setup

### Prerequisites

- Node.js installed on your system
- A YNAB account with transaction data

### Installation

1. Clone or download this repository

2. Install dependencies:
```bash
npm install
```

3. Create a YNAB OAuth Application:
   - Go to [YNAB Developer Settings](https://app.ynab.com/settings/developer)
   - Click "New Application" under "OAuth Applications"
   - Fill in the application details:
     - **Application Name**: YNAB Recurring Charges Finder (or your preferred name)
     - **Redirect URI(s)**:
       - For local development: `http://localhost:5173`
       - For production: your deployed URL (e.g., `https://yourdomain.com`)
   - Click "Save"
   - Copy your **Client ID** (you won't need the Client Secret for this app)

4. Configure environment variables:
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` and add your YNAB OAuth Client ID:
     ```
     VITE_YNAB_CLIENT_ID=your_client_id_here
     VITE_YNAB_REDIRECT_URI=http://localhost:5173
     ```

### Running the App

Start the development server:
```bash
npm run dev
```

The app will open at `http://localhost:5173`

**Important**: If Vite uses a different port (like 5174), update your `.env` file's `VITE_YNAB_REDIRECT_URI` to match, and also update the Redirect URI in your YNAB OAuth application settings.

### Building for Production

```bash
npm run build
```

The production build will be in the `dist` folder.

**For Production Deployment:**
1. Update your YNAB OAuth application settings to add your production URL as a Redirect URI
2. Update your production environment variables to use the production URL for `VITE_YNAB_REDIRECT_URI`

## How to Use

1. Click "Connect with YNAB" on the login screen
2. You'll be redirected to YNAB to authorize the app
3. After authorization, you'll be redirected back to the app
4. Select a budget from the dropdown
5. Click "Find Recurring Charges"
6. Browse the detected recurring charges, sorted by average amount
7. Click "View all transactions" to see the full history for each recurring charge

## How It Works

The app analyzes your transactions and identifies recurring charges by:
- Grouping transactions by payee name
- Calculating the average interval between transactions
- Filtering for charges that occur regularly (every 7-400 days)
- Excluding income, transfers, and one-time purchases

## Security & Privacy

- This app uses OAuth 2.0 implicit flow for secure authentication
- Your access token is stored only in your browser's sessionStorage
- The token is cleared when you close the browser or click "Logout"
- All API calls go directly from your browser to YNAB's API
- No data is sent to any third-party servers

## Built With

- [React](https://react.dev/) - UI framework
- [Vite](https://vite.dev/) - Build tool
- [YNAB API](https://api.ynab.com/) - Financial data
- [ynab](https://www.npmjs.com/package/ynab) - Official YNAB JavaScript SDK

## Troubleshooting

**"OAuth Client ID is not configured" error:**
- Make sure you've created a `.env` file (copy from `.env.example`)
- Verify your Client ID is correctly set in the `.env` file
- Restart the development server after changing `.env` files

**Redirect URI mismatch error:**
- The redirect URI in your `.env` file must exactly match one of the Redirect URIs configured in your YNAB OAuth application
- Check that the port number matches (e.g., 5173 vs 5174)
- Make sure there are no trailing slashes

**"Failed to fetch budgets" error:**
- Your OAuth token may have expired
- Click "Logout" and reconnect to get a new token
