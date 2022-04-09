const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
const database = admin.firestore();

exports.sendNotification = functions.pubsub.schedule('* * * * *').onRun(async (context) => {
    const query = await database.collection("notifications")
        .where("whenToNotify", '<=', admin.firestore.Timestamp.now())
        .where("notificationSent", "==", false).get();

    query.forEach(async snapshot => {
    console.log(snapshot.data());
    const payload = {
    	token: snapshot.data().token,
        notification: {
            title: snapshot.data().title,
            body: "Hey! " + snapshot.data().user + ", You have to complete a task!"
        },
        android: {
            priority: "high",
            notification: {
               'channel_id': 'task',
            },
          },
        data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
    };

    admin.messaging().send(payload).then((response) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', response);
        admin.firestore().collection('notifications').doc(snapshot.data().id).update({"notificationSent": true,})
        //changeDataConfirm(snapshot.data().token);
        return {success: true};
    }).then(() => {
          response.end();
      }).catch(error => {
                    return console.log("Error Sending Message");
                });


        //sendNotification(snapshot.data().token);

    });


async function changeDataConfirm(fcmToken)
{
console.log("done");
await database.collection('notifications').doc('fcmToken').update({"notificationSent": true,});
//    await database.doc('notifications/' + fcmToken).update({
//                        "notificationSent": true,
//    });
}

//    function sendNotification(androidNotificationToken) {
//        let title = "Timed Notification";
//        let body = "Comes at the right time";
//
//        const message = {
//            notification: { title: title, body: body },
//            token: androidNotificationToken,
//            data: { click_action: 'FLUTTER_NOTIFICATION_CLICK' }
//        };
//
//        admin.messaging().send(message).then(response => {
//            return console.log("Successful Message Sent");
//        }).catch(error => {
//            return console.log("Error Sending Message");
//        });
//    }
    return console.log('End Of Function');
});