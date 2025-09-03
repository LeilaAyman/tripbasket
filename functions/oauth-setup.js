const { google } = require('googleapis');
const readline = require('readline');

console.log('🔧 Gmail OAuth2 Setup Helper\n');

// Step 1: Instructions for Google Cloud Console
console.log('📋 STEP 1: Google Cloud Console Setup');
console.log('1. Go to: https://console.cloud.google.com/');
console.log('2. Select your Firebase project: tripbasket-sctkxj');
console.log('3. Go to "APIs & Services" → "Credentials"');
console.log('4. Click "Create Credentials" → "OAuth 2.0 Client IDs"');
console.log('5. Choose "Web application"');
console.log('6. Add authorized redirect URI: https://developers.google.com/oauthplayground');
console.log('7. Copy the Client ID and Client Secret\n');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

async function setupOAuth() {
  try {
    console.log('📝 Enter your OAuth credentials:\n');
    
    const clientId = await askQuestion('Enter your Client ID: ');
    const clientSecret = await askQuestion('Enter your Client Secret: ');
    const email = await askQuestion('Enter your Gmail address: ');

    console.log('\n🔗 STEP 2: Get Refresh Token');
    console.log('1. Go to: https://developers.google.com/oauthplayground');
    console.log('2. Click the settings gear (⚙️) in top right');
    console.log('3. Check "Use your own OAuth credentials"');
    console.log('4. Enter your Client ID and Client Secret');
    console.log('5. In left sidebar, scroll to "Gmail API v1"');
    console.log('6. Select "https://mail.google.com"');
    console.log('7. Click "Authorize APIs"');
    console.log('8. Sign in with your Gmail account');
    console.log('9. Click "Exchange authorization code for tokens"');
    console.log('10. Copy the "Refresh token"\n');

    const refreshToken = await askQuestion('Enter your Refresh Token: ');

    console.log('\n🚀 STEP 3: Configure Firebase Functions');
    console.log('Run these commands:\n');
    console.log(`firebase functions:config:set gmail.email="${email}"`);
    console.log(`firebase functions:config:set gmail.client_id="${clientId}"`);
    console.log(`firebase functions:config:set gmail.client_secret="${clientSecret}"`);
    console.log(`firebase functions:config:set gmail.refresh_token="${refreshToken}"`);
    console.log('\nfirebase deploy --only functions');

    console.log('\n✅ Setup complete! Your Gmail OAuth2 is configured.');
    console.log('The old gmail.password config will be ignored.');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    rl.close();
  }
}

setupOAuth();