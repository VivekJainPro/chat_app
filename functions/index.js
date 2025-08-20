const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
exports.myFunction = functions.firestore
  .document('chat/{messageId}')
  .onCreate(async (snapshot, context) => {
    try {
      const data = snapshot.data(); // Get the document data
      if (!data) {
        console.error('No data found in the snapshot.');
        return null;
      }

      // Prepare the notification message
      const message = {
        notification: {
          title: data.userId || 'New Message',
          body: data.chat || 'You have a new message.',
        },
        data: {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        topic: 'chat',
      };

      // Send the notification
      await admin.messaging().send(message);
      console.log('Notification sent successfully.');
      return null;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });