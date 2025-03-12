const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onCreate((snap, context) => {
        console.log('----------------start function--------------------')
        const doc = snap.data()
        console.log(doc)

        const idFrom = doc.idFrom
        const idTo = doc.idTo
        const contentMessage = doc.content

        // Get push token of the user to (receive)
        admin
            .firestore()
            .collection('user')
            .where('id', '==', idTo)
            .get()
            .then(querySnapshot => {
                querySnapshot.forEach(userTo => {
                    console.log(`Found user to: ${userTo.data().name}`)
                    console.log(`Found user chatWith : ${userTo.data().chatWith[0]}`)
                    console.log(`Send from : ${idFrom}`)

                    // Check if the user has a push token and is chatting with the sender
                    if (userTo.data().token && userTo.data().chatWith[0] === idFrom) {
                        // Get info of the user from (sent)
                        admin
                            .firestore()
                            .collection('user')
                            .where('id', '==', idFrom)
                            .get()
                            .then(querySnapshot2 => {
                                querySnapshot2.forEach(userFrom => {
                                    console.log(`Found user from: ${userFrom.data().name}`)

                                    // Construct the message payload
                                    const message = {
                                        token: userTo.data().token, // Target device's push token
                                        notification: {
                                            title: `${userFrom.data().name} sent a message`,
                                            body: 'New Message',
                                        },
                                        android: {
                                            notification: {
                                                sound: 'default',
                                            }
                                        },
                                        apns: {
                                            payload: {
                                                aps: {
                                                    sound: 'default',
                                                }
                                            }
                                        }
                                    }

                                    // Send the notification to the target device
                                    admin
                                        .messaging()
                                        .send(message)
                                        .then(response => {
                                            console.log('Successfully sent message:', response)
                                        })
                                        .catch(error => {
                                            console.log('Error sending message:', error)
                                        })
                                })
                            })
                    } else {
                        console.log('Cannot find pushToken or user is not chatting with the sender')
                    }
                })
            })
        return null
    })
